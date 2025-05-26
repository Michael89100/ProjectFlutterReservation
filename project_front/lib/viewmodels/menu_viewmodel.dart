import 'package:flutter/foundation.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';

enum MenuState {
  initial,
  loading,
  loaded,
  error,
}

class MenuViewModel extends ChangeNotifier {
  final MenuService _menuService = MenuService.instance;

  MenuState _state = MenuState.initial;
  List<MenuModel> _allMenus = [];
  List<MenuModel> _filteredMenus = [];
  String _errorMessage = '';
  bool _isLoading = false;

  // Filtres
  String _searchQuery = '';
  String? _selectedCategory;
  bool? _availabilityFilter;

  // Getters
  MenuState get state => _state;
  List<MenuModel> get menus => _filteredMenus;
  List<MenuModel> get allMenus => _allMenus;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool? get availabilityFilter => _availabilityFilter;

  // Getters pour les listes filtrées
  List<MenuModel> get availableMenus => _allMenus.where((menu) => menu.disponible).toList();
  List<String> get categories => _allMenus.map((menu) => menu.categorie).where((cat) => cat.isNotEmpty).toSet().toList();

  // Charger les menus
  Future<void> loadMenus() async {
    _setLoading(true);
    _clearError();

    try {
      final menus = await _menuService.getMenus();
      _allMenus = menus;
      _applyFilters();
      _setState(MenuState.loaded);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Rafraîchir les menus
  Future<void> refreshMenus() async {
    await loadMenus();
  }

  // Recherche
  void searchMenus(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Filtrage par catégorie
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Filtrage par disponibilité
  void filterByAvailability(bool? available) {
    _availabilityFilter = available;
    _applyFilters();
    notifyListeners();
  }

  // Tri
  void sortByName({bool ascending = true}) {
    _filteredMenus.sort((a, b) {
      final comparison = a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    notifyListeners();
  }

  void sortByPrice({bool ascending = true}) {
    _filteredMenus.sort((a, b) {
      final comparison = a.prix.compareTo(b.prix);
      return ascending ? comparison : -comparison;
    });
    notifyListeners();
  }

  void sortByAvailability() {
    _filteredMenus.sort((a, b) {
      if (a.disponible && !b.disponible) return -1;
      if (!a.disponible && b.disponible) return 1;
      return 0;
    });
    notifyListeners();
  }

  // Appliquer tous les filtres
  void _applyFilters() {
    _filteredMenus = _allMenus.where((menu) {
      // Filtre de recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!menu.nom.toLowerCase().contains(query) &&
            !menu.description.toLowerCase().contains(query) &&
            !menu.categorie.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtre par catégorie
      if (_selectedCategory != null && menu.categorie != _selectedCategory) {
        return false;
      }

      // Filtre par disponibilité
      if (_availabilityFilter != null && menu.disponible != _availabilityFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  // Méthodes privées pour gérer l'état
  void _setState(MenuState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = MenuState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    if (_state == MenuState.error) {
      _state = MenuState.initial;
    }
    notifyListeners();
  }

  // Nettoyer les erreurs manuellement
  void clearError() {
    _clearError();
  }

  // Réinitialiser tous les filtres
  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _availabilityFilter = null;
    _applyFilters();
    notifyListeners();
  }
} 