class MenuModel {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final String image_url;
  final bool disponible;
  final String categorie;

  MenuModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.image_url,
    required this.disponible,
    required this.categorie,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      prix: (json['prix'] ?? 0).toDouble(),
      image_url: json['image_url'] ?? '',
      disponible: json['disponible'] ?? false,
      categorie: json['categorie'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'image_url': image_url,
      'disponible': disponible,
      'categorie': categorie,
    };
  }

  @override
  String toString() {
    return 'MenuModel{id: $id, nom: $nom, description: $description, prix: $prix, image_url: $image_url, disponible: $disponible, categorie: $categorie}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 