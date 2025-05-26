import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../services/storage_service.dart';
import '../services/mock_reservation_service.dart';

class ReservationManagementViewModel extends ChangeNotifier {
  final ReservationService _reservationService = ReservationService.instance;
  final StorageService _storageService = StorageService.instance;

  List<Reservation> _reservations = [];
  List<Reservation> _filteredReservations = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'tous'; // 'tous', 'en attente', 'acceptée', 'refusée'

  // Getters
  List<Reservation> get reservations => _filteredReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedFilter => _selectedFilter;
  
  int get totalReservations => _reservations.length;
  int get pendingReservations => _reservations.where((r) => r.status == 'en attente').length;
  int get acceptedReservations => _reservations.where((r) => r.status == 'acceptée').length;
  int get refusedReservations => _reservations.where((r) => r.status == 'refusée').length;

  /// Charge toutes les réservations
  Future<void> loadReservations() async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      try {
        _reservations = await _reservationService.getAllReservations(token);
      } catch (e) {
        print('Erreur API, utilisation des données de test: $e');
        // En cas d'erreur API, utiliser les données de test
        _reservations = MockReservationService.getMockReservations();
      }
      
      _applyFilter();
      
      print('Réservations chargées: ${_reservations.length}');
    } catch (e) {
      // En dernier recours, utiliser les données de test
      print('Erreur générale, utilisation des données de test: $e');
      _reservations = MockReservationService.getMockReservations();
      _applyFilter();
    } finally {
      _setLoading(false);
    }
  }

  /// Filtre les réservations par statut
  void filterReservations(String filter) {
    _selectedFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  /// Applique le filtre sélectionné
  void _applyFilter() {
    print('Application du filtre: $_selectedFilter');
    print('Réservations totales: ${_reservations.length}');
    
    // Debug: afficher tous les statuts
    for (var reservation in _reservations) {
      print('Réservation ${reservation.id}: statut="${reservation.status}"');
    }
    
    switch (_selectedFilter) {
      case 'en attente':
        _filteredReservations = _reservations.where((r) => r.status == 'en attente').toList();
        break;
      case 'acceptée':
        _filteredReservations = _reservations.where((r) => r.status == 'acceptée').toList();
        break;
      case 'refusée':
        _filteredReservations = _reservations.where((r) => r.status == 'refusée').toList();
        break;
      default:
        _filteredReservations = List.from(_reservations);
    }

    print('Réservations filtrées: ${_filteredReservations.length}');

    // Trier par date de création (plus récent en premier)
    _filteredReservations.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
  }

  /// Accepte une réservation
  Future<bool> acceptReservation(String reservationId, {String? commentaire}) async {
    return _updateReservationStatus(reservationId, 'acceptee', commentaire: commentaire);
  }

  /// Refuse une réservation
  Future<bool> refuseReservation(String reservationId, {String? commentaire}) async {
    return _updateReservationStatus(reservationId, 'refusee', commentaire: commentaire);
  }

  /// Met à jour le statut d'une réservation
  Future<bool> _updateReservationStatus(String reservationId, String newStatus, {String? commentaire}) async {
    try {
      print('Tentative de mise à jour de la réservation: $reservationId vers $newStatus');
      
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      final updatedReservation = await _reservationService.updateReservationStatus(
        token, 
        reservationId, 
        newStatus, 
        commentaire: commentaire
      );

      print('Réservation mise à jour avec succès: ${updatedReservation.id} - ${updatedReservation.status}');

      // Mettre à jour la réservation dans la liste locale
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = updatedReservation;
        _applyFilter();
        notifyListeners();
        print('Liste locale mise à jour, index: $index');
      } else {
        print('Réservation non trouvée dans la liste locale: $reservationId');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      print('Erreur lors de la mise à jour de la réservation: $e');
      return false;
    }
  }

  /// Actualise les données
  Future<void> refresh() async {
    await loadReservations();
  }

  /// Définit l'état de chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Définit l'erreur
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Efface l'erreur
  void clearError() {
    _setError(null);
  }

  /// Obtient la couleur associée au statut
  static String getStatusColor(String status) {
    switch (status) {
      case 'en attente':
        return '#FF9800'; // Orange
      case 'acceptée':
        return '#4CAF50'; // Vert
      case 'refusée':
        return '#F44336'; // Rouge
      default:
        return '#9E9E9E'; // Gris
    }
  }

  /// Obtient l'icône associée au statut
  static String getStatusIcon(String status) {
    switch (status) {
      case 'en attente':
        return '⏳';
      case 'acceptée':
        return '✅';
      case 'refusée':
        return '❌';
      default:
        return '❓';
    }
  }
} 