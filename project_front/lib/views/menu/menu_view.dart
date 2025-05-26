import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../components/menu_card.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyAvailable = false;
  String _sortBy = 'name'; // 'name', 'price', 'availability'
  bool _sortAscending = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuViewModel>().loadMenus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Plats'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          // Bouton de tri
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _handleSort,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name_asc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'name' && _sortAscending 
                          ? Icons.check 
                          : Icons.sort_by_alpha,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Nom (A-Z)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name_desc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'name' && !_sortAscending 
                          ? Icons.check 
                          : Icons.sort_by_alpha,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Nom (Z-A)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price_asc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'price' && _sortAscending 
                          ? Icons.check 
                          : Icons.euro,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Prix croissant'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price_desc',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'price' && !_sortAscending 
                          ? Icons.check 
                          : Icons.euro,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Prix décroissant'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'availability',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'availability' 
                          ? Icons.check 
                          : Icons.check_circle,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Disponibilité'),
                  ],
                ),
              ),
            ],
          ),
          
          // Bouton de rafraîchissement
          Consumer<MenuViewModel>(
            builder: (context, menuViewModel, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: menuViewModel.isLoading 
                    ? null 
                    : () => menuViewModel.refreshMenus(),
                tooltip: 'Actualiser',
              );
            },
          ),
        ],
      ),
      body: Consumer<MenuViewModel>(
        builder: (context, menuViewModel, child) {
          return Column(
            children: [
              // Barre de recherche et filtres
              _buildSearchAndFilters(menuViewModel),
              
              // Contenu principal
              Expanded(
                child: _buildContent(menuViewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(MenuViewModel menuViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un plat...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        menuViewModel.clearSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            onChanged: (value) => menuViewModel.searchMenus(value),
          ),
          
          const SizedBox(height: 12),
          
          // Filtres par catégorie
          if (menuViewModel.categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: menuViewModel.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Toutes'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = null;
                            });
                            menuViewModel.filterByCategory(null);
                          }
                        },
                        avatar: const Icon(Icons.restaurant_menu, size: 18),
                      ),
                    );
                  }
                  
                  final category = menuViewModel.categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_formatCategoryLabel(category)),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        menuViewModel.filterByCategory(selected ? category : null);
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Filtre de disponibilité et compteur
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Disponibles uniquement'),
                  selected: _showOnlyAvailable,
                  onSelected: (selected) {
                    setState(() {
                      _showOnlyAvailable = selected;
                    });
                    menuViewModel.filterByAvailability(selected ? true : null);
                  },
                  avatar: Icon(
                    _showOnlyAvailable ? Icons.check_circle : Icons.filter_list,
                    size: 18,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Compteur de résultats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${menuViewModel.menus.length} plat${menuViewModel.menus.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MenuViewModel menuViewModel) {
    if (menuViewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des plats...'),
          ],
        ),
      );
    }

    if (menuViewModel.state == MenuState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              menuViewModel.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => menuViewModel.loadMenus(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (menuViewModel.menus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun plat trouvé',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              menuViewModel.searchQuery.isNotEmpty
                  ? 'Aucun plat ne correspond à votre recherche'
                  : 'Aucun plat disponible pour le moment',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (menuViewModel.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  menuViewModel.clearSearch();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Effacer la recherche'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => menuViewModel.refreshMenus(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menuViewModel.menus.length + 1, // +1 pour le bouton de réservation
        itemBuilder: (context, index) {
          // Bouton de réservation en premier
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Consumer<AuthViewModel>(
                builder: (context, authViewModel, child) {
                  return FilledButton.icon(
                    onPressed: () {
                      if (authViewModel.isAuthenticated) {
                        // TODO: Rediriger vers la page de réservation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité de réservation à venir !'),
                          ),
                        );
                      } else {
                        Navigator.of(context).pushNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.event_seat),
                    label: Text(authViewModel.isAuthenticated 
                        ? 'Réserver une table' 
                        : 'Se connecter pour réserver'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  );
                },
              ),
            );
          }
          
          // Plats (index - 1 car le bouton est en premier)
          final menu = menuViewModel.menus[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MenuCard(
              menu: menu,
              onTap: () => _showMenuDetails(context, menu),
            ),
          );
        },
      ),
    );
  }

  void _handleSort(String value) {
    final menuViewModel = context.read<MenuViewModel>();
    
    setState(() {
      switch (value) {
        case 'name_asc':
          _sortBy = 'name';
          _sortAscending = true;
          break;
        case 'name_desc':
          _sortBy = 'name';
          _sortAscending = false;
          break;
        case 'price_asc':
          _sortBy = 'price';
          _sortAscending = true;
          break;
        case 'price_desc':
          _sortBy = 'price';
          _sortAscending = false;
          break;
        case 'availability':
          _sortBy = 'availability';
          break;
      }
    });

    switch (_sortBy) {
      case 'name':
        menuViewModel.sortByName(ascending: _sortAscending);
        break;
      case 'price':
        menuViewModel.sortByPrice(ascending: _sortAscending);
        break;
      case 'availability':
        menuViewModel.sortByAvailability();
        break;
    }
  }

  void _showMenuDetails(BuildContext context, menu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle pour le drag
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: MenuCard(
                      menu: menu,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Formate le label de la catégorie : majuscule + remplace _ par espace
  String _formatCategoryLabel(String category) {
    if (category.isEmpty) return category;
    
    // Remplacer les underscores par des espaces
    String formatted = category.replaceAll('_', ' ');
    
    // Mettre la première lettre en majuscule et le reste en minuscule
    formatted = formatted.toLowerCase();
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }
    
    return formatted;
  }
} 