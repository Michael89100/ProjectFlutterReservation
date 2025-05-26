import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Erreur lors de la sauvegarde du token: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      return await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'utilisateur: $e');
      return false;
    }
  }

  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  Future<bool> setLoggedIn(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_isLoggedInKey, isLoggedIn);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de connexion: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Erreur lors de la vérification du statut de connexion: $e');
      return false;
    }
  }

  Future<bool> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_isLoggedInKey);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression des données d\'authentification: $e');
      return false;
    }
  }

  Future<bool> saveAuthData(String token, User user) async {
    try {
      final tokenSaved = await saveToken(token);
      final userSaved = await saveUser(user);
      final statusSaved = await setLoggedIn(true);
      
      return tokenSaved && userSaved && statusSaved;
    } catch (e) {
      print('Erreur lors de la sauvegarde des données d\'authentification: $e');
      return false;
    }
  }
} 