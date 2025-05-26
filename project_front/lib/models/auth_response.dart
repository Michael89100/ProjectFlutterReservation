import 'user_model.dart';

class AuthResponse {
  final String token;
  final User user;
  final String message;

  AuthResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Gérer les deux structures de réponse possibles
    if (json.containsKey('data')) {
      // Structure backend: { success, message, data: { user, token } }
      final data = json['data'] as Map<String, dynamic>;
      return AuthResponse(
        token: data['token'] ?? '',
        user: User.fromJson(data['user'] ?? {}),
        message: json['message'] ?? '',
      );
    } else {
      // Structure directe: { token, user, message }
      return AuthResponse(
        token: json['token'] ?? '',
        user: User.fromJson(json['user'] ?? {}),
        message: json['message'] ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'message': message,
    };
  }
}

class AuthRequest {
  final String email;
  final String password;

  AuthRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String role;

  RegisterRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    this.role = 'client',
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'role': role,
    };
  }
} 