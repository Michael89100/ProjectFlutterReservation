import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';

class ReservationService implements Exception{
  static const String baseUrl = 'http://localhost:3000/api';
  
  static ReservationService? _instance;
  static ReservationService get instance => _instance ??= ReservationService._();
  
  ReservationService._();
  // Ajout d'un constructeur par défaut pour permettre l'instanciation avec ReservationService()
  ReservationService();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _headersWithAuth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  /// Récupère toutes les réservations (pour les serveurs)
  Future<List<Reservation>> getAllReservations(String token, {String? status}) async {
    try {
      String url = '$baseUrl/reservations';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headersWithAuth(token),
      );

      print('Get Reservations Response Status: ${response.statusCode}');
      print('Get Reservations Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Gérer différents formats de réponse
        List<dynamic> reservationsJson;
        if (responseData is Map<String, dynamic>) {
          reservationsJson = responseData['reservations'] ?? responseData['data'] ?? [];
        } else if (responseData is List) {
          reservationsJson = responseData;
        } else {
          throw ReservationException(
            message: 'Format de réponse inattendu',
            statusCode: response.statusCode,
          );
        }

        return reservationsJson
            .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ReservationException(
          message: errorData['message'] ?? 'Erreur lors de la récupération des réservations',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ReservationException(
        message: 'Erreur de connexion réseau. Vérifiez votre connexion internet.',
        statusCode: 0,
      );
    } on FormatException {
      throw ReservationException(
        message: 'Erreur de format de réponse du serveur.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ReservationException) rethrow;
      throw ReservationException(
        message: 'Erreur inattendue: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Met à jour le statut d'une réservation
  Future<Reservation> updateReservationStatus(
    String token, 
    String reservationId, 
    String newStatus, 
    {String? commentaire}
  ) async {
    try {
      final body = {
        'status': newStatus,
        if (commentaire != null && commentaire.isNotEmpty) 'commentaire': commentaire,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/reservations/$reservationId'),
        headers: _headersWithAuth(token),
        body: jsonEncode(body),
      );

      print('Update Reservation Response Status: ${response.statusCode}');
      print('Update Reservation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Gérer différents formats de réponse
        Map<String, dynamic> reservationJson;
        if (responseData.containsKey('reservation')) {
          reservationJson = responseData['reservation'];
        } else if (responseData.containsKey('data')) {
          reservationJson = responseData['data'];
        } else {
          reservationJson = responseData;
        }

        return Reservation.fromJson(reservationJson);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ReservationException(
          message: errorData['message'] ?? 'Erreur lors de la mise à jour de la réservation',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ReservationException(
        message: 'Erreur de connexion réseau. Vérifiez votre connexion internet.',
        statusCode: 0,
      );
    } on FormatException {
      throw ReservationException(
        message: 'Erreur de format de réponse du serveur.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ReservationException) rethrow;
      throw ReservationException(
        message: 'Erreur inattendue: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Accepte une réservation
  Future<Reservation> acceptReservation(String token, String reservationId, {String? commentaire}) async {
    return updateReservationStatus(token, reservationId, 'acceptee', commentaire: commentaire);
  }

  /// Refuse une réservation
  Future<Reservation> refuseReservation(String token, String reservationId, {String? commentaire}) async {
    return updateReservationStatus(token, reservationId, 'refusee', commentaire: commentaire);
  }

  Future<bool> createReservation({
    String? token,
    String? userId,
    required int nombreCouverts,
    required DateTime date,
    required String heure,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
  }) async {
    final url = Uri.parse('$baseUrl/reservations');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> body = {
      'nombreCouverts': nombreCouverts,
      'horaire': '${date.toIso8601String().split('T')[0]}T$heure:00',
    };
    if (token != null && userId != null) {
      body['userId'] = userId;
    } else {
      // Utilisateur non connecté, on envoie toutes les infos pour créer un compte
      body['user'] = {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'role': 'client',
        'password': 'Temp${DateTime.now().millisecondsSinceEpoch}', // mot de passe temporaire
      };
    }
    print('DEBUG ReservationService: url=$url');
    print('DEBUG ReservationService: headers=' + headers.toString());
    print('DEBUG ReservationService: body=' + body.toString());
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    print('DEBUG ReservationService: statusCode=${response.statusCode}');
    print('DEBUG ReservationService: responseBody=${response.body}');
    if (response.statusCode == 201) {
      return true;
    } else {
      print('Erreur réservation: ${response.body}');
      return false;
    }
  }

  // Récupère les créneaux disponibles pour une date donnée (format YYYY-MM-DD)
  Future<List<Map<String, dynamic>>> getAvailableSlots(DateTime date) async {
    final String dateStr = date.toIso8601String().split('T')[0];
    final url = Uri.parse('$baseUrl/reservations/available-slots?date=$dateStr');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final slots = (data['slots'] as List<dynamic>?) ?? [];
      return slots.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des créneaux');
    }
  }

  /// Supprime une réservation (client uniquement)
  Future<void> deleteReservation(String token, String reservationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reservations/$reservationId'),
        headers: _headersWithAuth(token),
      );

      print('Delete Reservation Response Status: ${response.statusCode}');
      print('Delete Reservation Response Body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ReservationException(
          message: errorData['message'] ?? 'Erreur lors de la suppression de la réservation',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ReservationException(
        message: 'Erreur de connexion réseau. Vérifiez votre connexion internet.',
        statusCode: 0,
      );
    } on FormatException {
      throw ReservationException(
        message: 'Erreur de format de réponse du serveur.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ReservationException) rethrow;
      throw ReservationException(
        message: 'Erreur inattendue: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Met à jour une réservation (client uniquement - horaire et nombre de couverts)
  Future<Reservation> updateReservation(
    String token, 
    String reservationId, 
    {DateTime? horaire, int? nombreCouverts, bool resetStatus = false}
  ) async {
    try {
      final body = <String, dynamic>{};
      if (horaire != null) {
        // Envoyer la date avec le fuseau horaire local pour éviter les conversions
        body['horaire'] = horaire.toIso8601String();
        print('Date envoyée au serveur: ${body['horaire']}');
      }
      if (nombreCouverts != null) body['nombreCouverts'] = nombreCouverts;
      if (resetStatus) body['status'] = 'en attente';

      final response = await http.patch(
        Uri.parse('$baseUrl/reservations/$reservationId'),
        headers: _headersWithAuth(token),
        body: jsonEncode(body),
      );

      print('Update Reservation Response Status: ${response.statusCode}');
      print('Update Reservation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Gérer différents formats de réponse
        Map<String, dynamic> reservationJson;
        if (responseData.containsKey('reservation')) {
          reservationJson = responseData['reservation'];
        } else if (responseData.containsKey('data')) {
          reservationJson = responseData['data'];
        } else {
          reservationJson = responseData;
        }

        return Reservation.fromJson(reservationJson);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw ReservationException(
          message: errorData['message'] ?? 'Erreur lors de la modification de la réservation',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ReservationException(
        message: 'Erreur de connexion réseau. Vérifiez votre connexion internet.',
        statusCode: 0,
      );
    } on FormatException {
      throw ReservationException(
        message: 'Erreur de format de réponse du serveur.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ReservationException) rethrow;
      throw ReservationException(
        message: 'Erreur inattendue: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}

class ReservationException implements Exception {
  final String message;
  final int statusCode;

  ReservationException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ReservationException: $message (Code: $statusCode)';
}
