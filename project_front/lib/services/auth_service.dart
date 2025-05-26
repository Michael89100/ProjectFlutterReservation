import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _headersWithAuth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  Future<AuthResponse> login(String email, String password) async {
    try {
      final request = AuthRequest(email: email, password: password);
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['message'] ?? 'Erreur de connexion',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw AuthException(
        message: 'Erreur de connexion réseau. Vérifiez votre connexion internet.',
        statusCode: 0,
      );
    } on FormatException {
      throw AuthException(
        message: 'Erreur de format de réponse du serveur.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Erreur inattendue: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  Future<AuthResponse> register(String nom, String prenom, String email, String password) async {
    try {
      final request = RegisterRequest(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
        role: 'client',
      );
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthException(
          message: errorData['message'] ?? 'Erreur lors de l\'inscription',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw AuthException(
        message: 'Erreur de connexion réseau. Vérifiez votre connexion internet.',
        statusCode: 0,
      );
    } on FormatException {
      throw AuthException(
        message: 'Erreur de format de réponse du serveur.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Erreur inattendue: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la vérification du token: $e');
      return false;
    }
  }

  Future<User?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(responseData['user'] ?? responseData);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      return false;
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int statusCode;

  AuthException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'AuthException: $message (Code: $statusCode)';
} 