import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservationService {
  static const String baseUrl = 'http://localhost:3000/api';

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
    print('DEBUG ReservationService: url=' + url.toString());
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
}
