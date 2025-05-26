import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../components/menu_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuViewModel>().loadMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              if (authViewModel.isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Déconnexion'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await authViewModel.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    }
                  },
                  tooltip: 'Se déconnecter',
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
                  tooltip: 'Se connecter',
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return _buildContent(authViewModel);
        },
      ),
    );
  }

  Widget _buildContent(AuthViewModel authViewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section de bienvenue
          _buildWelcomeSection(authViewModel),
          
          const SizedBox(height: 24),
          
          // Section du menu
          _buildMenuSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AuthViewModel authViewModel) {
    final user = authViewModel.currentUser;
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: user != null
                      ? Text(
                          '${user.prenom[0]}${user.nom[0]}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 30,
                          color: theme.colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue !',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        user != null 
                            ? '${user.prenom} ${user.nom}'
                            : 'Visiteur',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (!authViewModel.isAuthenticated) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Connectez-vous pour pouvoir faire des réservations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nos Plats',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/menu'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Voir tout'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Consumer<MenuViewModel>(
          builder: (context, menuViewModel, child) {
            if (menuViewModel.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (menuViewModel.state == MenuState.error) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Erreur lors du chargement des plats',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => menuViewModel.loadMenus(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (menuViewModel.menus.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun plat disponible',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Afficher les 3 premiers menus disponibles
            final availableMenus = menuViewModel.availableMenus.take(3).toList();
            
            return Column(
              children: [
                ...availableMenus.map((menu) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MenuCard(
                    menu: menu,
                    onTap: () => _showMenuDetails(context, menu),
                  ),
                )),
                
                // Bouton pour réserver une table
                Padding(
                  padding: const EdgeInsets.only(top: 16),
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
                ),

                if (menuViewModel.menus.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/menu'),
                      icon: const Icon(Icons.restaurant_menu),
                      label: Text('Voir tous les plats (${menuViewModel.menus.length})'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
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
}