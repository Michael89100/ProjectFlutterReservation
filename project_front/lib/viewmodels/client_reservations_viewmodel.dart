import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../services/storage_service.dart';

class ClientReservationsViewModel extends ChangeNotifier {
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


  /// Charge les réservations du client connecté
  Future<void> loadReservations() async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      // L'API retourne automatiquement les réservations du client connecté
      _reservations = await _reservationService.getAllReservations(token);
      
      _applyFilter();
      
      print('Réservations client chargées: ${_reservations.length}');
    } catch (e) {
      _setError('Erreur lors du chargement des réservations: ${e.toString()}');
      print('Erreur lors du chargement des réservations client: $e');
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

  /// Supprime une réservation (seul le client propriétaire peut supprimer)
  Future<bool> deleteReservation(String reservationId) async {
    try {
      print('Tentative de suppression de la réservation: $reservationId');
      
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      await _reservationService.deleteReservation(token, reservationId);

      print('Réservation supprimée avec succès: $reservationId');

      // Retirer la réservation de la liste locale
      _reservations.removeWhere((r) => r.id == reservationId);
      _applyFilter();
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression: ${e.toString()}');
      print('Erreur lors de la suppression de la réservation: $e');
      return false;
    }
  }

  /// Modifie une réservation (horaire et nombre de couverts)
  /// Si la réservation était acceptée ou refusée, elle repasse en attente
  Future<bool> updateReservation(String reservationId, {
    DateTime? horaire,
    int? nombreCouverts,
  }) async {
    try {
      print('Tentative de modification de la réservation: $reservationId');
      
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      // Trouver la réservation actuelle pour vérifier son statut
      final currentReservation = _reservations.firstWhere((r) => r.id == reservationId);
      bool shouldResetStatus = currentReservation.status == 'acceptée';

      final updatedReservation = await _reservationService.updateReservation(
        token, 
        reservationId, 
        horaire: horaire,
        nombreCouverts: nombreCouverts,
        resetStatus: shouldResetStatus,
      );

      print('Réservation modifiée avec succès: ${updatedReservation.id}');

      // Mettre à jour la réservation dans la liste locale
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = updatedReservation;
        _applyFilter();
        notifyListeners();
        print('Liste locale mise à jour, index: $index');
      }

      return true;
    } catch (e) {
      _setError('Erreur lors de la modification: ${e.toString()}');
      print('Erreur lors de la modification de la réservation: $e');
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