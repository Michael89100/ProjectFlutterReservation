import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final StorageService _storageService = StorageService.instance;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _token;
  String _errorMessage = '';
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get token => _token;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _token != null;

  // Initialiser le ViewModel
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        final token = await _storageService.getToken();
        final user = await _storageService.getUser();
        
        if (token != null && user != null) {
          // Vérifier si le token est toujours valide
          final isTokenValid = await _authService.verifyToken(token);
          if (isTokenValid) {
            _token = token;
            _currentUser = user;
            _setState(AuthState.authenticated);
          } else {
            // Token expiré, nettoyer les données
            await logout();
          }
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Erreur lors de l\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authService.login(email, password);
      
      // Sauvegarder les données d'authentification
      final saved = await _storageService.saveAuthData(
        authResponse.token,
        authResponse.user,
      );

      if (saved) {
        _token = authResponse.token;
        _currentUser = authResponse.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError('Erreur lors de la sauvegarde des données de connexion');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Inscription
  Future<bool> register(String nom, String prenom, String email, String password, String telephone) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authService.register(nom, prenom, email, password, telephone);
      
      // Ne pas connecter automatiquement après l'inscription
      // L'utilisateur devra se connecter manuellement
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Nettoyer les données locales (pas d'appel API pour le logout)
      await _storageService.clearAuthData();
      
      _token = null;
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      // Même en cas d'erreur, on force la déconnexion locale
      _token = null;
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }



  // Méthodes privées pour gérer l'état
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
    notifyListeners();
  }

  // Nettoyer les erreurs manuellement
  void clearError() {
    _clearError();
  }
} 