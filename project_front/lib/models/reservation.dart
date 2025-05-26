class Reservation {
  final String nom;
  final String telephone;
  final int nombreCouverts;

  Reservation({
    required this.nom,
    required this.telephone,
    required this.nombreCouverts,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'telephone': telephone,
      'nombreCouverts': nombreCouverts,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      nom: json['nom'],
      telephone: json['telephone'],
      nombreCouverts: json['nombreCouverts'],
    );
  }
} 