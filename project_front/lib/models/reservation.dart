class Reservation {
  final String? id;
  final String nom;
  final String? prenom;
  final String telephone;
  final String? email;
  final int nombreCouverts;
  final DateTime? dateReservation;
  final DateTime? horaire;
  final String status; // 'en_attente', 'acceptee', 'refusee'
  final String? commentaire;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reservation({
    this.id,
    required this.nom,
    this.prenom,
    required this.telephone,
    this.email,
    required this.nombreCouverts,
    this.dateReservation,
    this.horaire,
    this.status = 'en attente',
    this.commentaire,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      if (prenom != null) 'prenom': prenom,
      'telephone': telephone,
      if (email != null) 'email': email,
      'nombreCouverts': nombreCouverts,
      if (dateReservation != null) 'dateReservation': dateReservation!.toIso8601String(),
      if (horaire != null) 'horaire': horaire!.toIso8601String(),
      'status': status,
      if (commentaire != null) 'commentaire': commentaire,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // Normaliser le statut pour l'affichage interne
    String normalizeStatus(String? status) {
      if (status == null) return 'en attente';
      // Convertir les statuts API vers les statuts d'affichage
      switch (status.toLowerCase()) {
        case 'acceptee':
          return 'acceptée';
        case 'refusee':
          return 'refusée';
        case 'en_attente':
          return 'en attente';
        default:
          return status;
      }
    }

    return Reservation(
      id: json['id']?.toString(),
      nom: json['nom'] ?? json['name'] ?? 'Client',
      prenom: json['prenom'] ?? json['firstname'],
      telephone: json['telephone'] ?? json['phone'] ?? '',
      email: json['email'],
      nombreCouverts: json['nombreCouverts'] ?? json['guests'] ?? 0,
      dateReservation: json['dateReservation'] != null 
          ? DateTime.parse(json['dateReservation']) 
          : (json['date'] != null ? DateTime.parse(json['date']) : null),
      horaire: json['horaire'] != null 
          ? DateTime.parse(json['horaire']) 
          : null,
      status: normalizeStatus(json['status']),
      commentaire: json['commentaire'] ?? json['comment'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : (json['date'] != null ? DateTime.parse(json['date']) : null),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Reservation copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    int? nombreCouverts,
    DateTime? dateReservation,
    DateTime? horaire,
    String? status,
    String? commentaire,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      nombreCouverts: nombreCouverts ?? this.nombreCouverts,
      dateReservation: dateReservation ?? this.dateReservation,
      horaire: horaire ?? this.horaire,
      status: status ?? this.status,
      commentaire: commentaire ?? this.commentaire,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case 'en attente':
        return 'En attente';
      case 'acceptée':
        return 'Acceptée';
      case 'refusée':
        return 'Refusée';
      default:
        return status;
    }
  }
} 