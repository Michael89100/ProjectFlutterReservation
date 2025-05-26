class User {
  final String? id;
  final String nom;
  final String prenom;
  final String email;
  final String role;

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.role = 'client',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
    };
  }

  Map<String, dynamic> toRegisterJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, nom: $nom, prenom: $prenom, email: $email, role: $role}';
  }
} 