import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';

class MenuService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static MenuService? _instance;
  static MenuService get instance => _instance ??= MenuService._();
  
  MenuService._();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<MenuModel>> getMenus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu'),
        headers: _headers,
      );

      print('Menu Response Status: ${response.statusCode}');
      print('Menu Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Gérer le format API spécifique : {success, message, data: {plats: [...]}}
        if (responseData.containsKey('data') && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data.containsKey('plats') && data['plats'] is List) {
            final platsList = data['plats'] as List;
            return platsList.map((json) => MenuModel.fromJson(json as Map<String, dynamic>)).toList();
          }
        }
        
        // Format de fallback si l'API retourne directement une liste dans responseData
        if (responseData.containsKey('plats') && responseData['plats'] is List) {
          final platsList = responseData['plats'] as List;
          return platsList.map((json) => MenuModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        // Données de test temporaires si l'API n'est pas disponible
        return _getTestMenus();
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw MenuException(
          message: errorData['message'] ?? 'Erreur lors du chargement du menu',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      // Retourner des données de test si pas de connexion réseau
      print('Pas de connexion réseau, utilisation des données de test');
      return _getTestMenus();
    } on FormatException {
      throw MenuException(
        message: 'Erreur de format de réponse du serveur.',
        statusCode: 0,
      );
    } catch (e) {
      if (e is MenuException) rethrow;
      print('Erreur lors du chargement du menu: $e');
      // Retourner des données de test en cas d'erreur
      return _getTestMenus();
    }
  }

  List<MenuModel> _getTestMenus() {
    return [
      MenuModel(
        id: '1',
        nom: 'Coq au Vin',
        description: 'Coq mijoté dans un vin rouge de Bourgogne avec des champignons et des lardons',
        prix: 24.50,
        image_url: 'https://images.unsplash.com/photo-1544025162-d76694265947',
        disponible: true,
        categorie: 'plat_principal',
      ),
      MenuModel(
        id: '2',
        nom: 'Foie Gras Poêlé',
        description: 'Foie gras poêlé aux figues confites et pain d\'épices',
        prix: 32.00,
        image_url: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641',
        disponible: true,
        categorie: 'entree',
      ),
      MenuModel(
        id: '3',
        nom: 'Crème Brûlée',
        description: 'Crème brûlée à la vanille de Madagascar',
        prix: 8.50,
        image_url: 'https://images.unsplash.com/photo-1551024506-0bccd828d307',
        disponible: true,
        categorie: 'dessert',
      ),
      MenuModel(
        id: '4',
        nom: 'Bouillabaisse',
        description: 'Soupe de poissons méditerranéenne avec rouille et croûtons',
        prix: 28.00,
        image_url: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
        disponible: true,
        categorie: 'plat_principal',
      ),
      MenuModel(
        id: '5',
        nom: 'Escargots de Bourgogne',
        description: 'Escargots au beurre persillé, ail et fines herbes',
        prix: 12.00,
        image_url: 'https://images.unsplash.com/photo-1565299507177-b0ac66763828',
        disponible: false,
        categorie: 'entree',
      ),
      MenuModel(
        id: '6',
        nom: 'Tarte Tatin',
        description: 'Tarte aux pommes caramélisées servie tiède',
        prix: 9.00,
        image_url: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187',
        disponible: true,
        categorie: 'dessert',
      ),
      MenuModel(
        id: '7',
        nom: 'Vin Rouge Bordeaux',
        description: 'Château Margaux 2018, grand cru classé',
        prix: 15.00,
        image_url: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb',
        disponible: true,
        categorie: 'boisson',
      ),
      MenuModel(
        id: '8',
        nom: 'Plateau de Fromages',
        description: 'Sélection de fromages français affinés',
        prix: 14.00,
        image_url: 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d',
        disponible: true,
        categorie: 'dessert',
      ),
      MenuModel(
        id: '9',
        nom: 'Soupe à l\'Oignon',
        description: 'Soupe à l\'oignon gratinée au fromage',
        prix: 8.00,
        image_url: 'https://images.unsplash.com/photo-1547592166-23ac45744acd',
        disponible: true,
        categorie: 'entree',
      ),
      MenuModel(
        id: '10',
        nom: 'Bœuf Bourguignon',
        description: 'Bœuf mijoté au vin rouge avec légumes de saison',
        prix: 26.00,
        image_url: 'https://images.unsplash.com/photo-1574484284002-952d92456975',
        disponible: true,
        categorie: 'plat_principal',
      ),
      MenuModel(
        id: '11',
        nom: 'Champagne Brut',
        description: 'Champagne Dom Pérignon millésimé',
        prix: 25.00,
        image_url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64',
        disponible: true,
        categorie: 'boisson',
      ),
      MenuModel(
        id: '12',
        nom: 'Mousse au Chocolat',
        description: 'Mousse au chocolat noir 70% cacao',
        prix: 7.50,
        image_url: 'https://images.unsplash.com/photo-1541599468348-e96984315921',
        disponible: true,
        categorie: 'dessert',
      ),
    ];
  }
}

class MenuException implements Exception {
  final String message;
  final int statusCode;

  MenuException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'MenuException: $message (Code: $statusCode)';
} 