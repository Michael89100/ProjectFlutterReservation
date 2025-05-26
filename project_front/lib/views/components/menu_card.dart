import 'package:flutter/material.dart';
import '../../models/menu_model.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.menu,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du menu
            _buildMenuImage(context),
            
            // Contenu du menu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie
                  if (menu.categorie.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatCategoryLabel(menu.categorie),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Nom et badge de disponibilité
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          menu.nom,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: menu.disponible 
                                ? colorScheme.onSurface 
                                : colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildAvailabilityBadge(context),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    menu.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: menu.disponible 
                          ? colorScheme.onSurfaceVariant 
                          : colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Prix
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${menu.prix.toStringAsFixed(2)} €',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
      ),
      child: menu.image_url.isNotEmpty
          ? Stack(
              children: [
                Image.network(
                  menu.image_url,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage(context);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
                if (!menu.disponible)
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Icon(
                        Icons.block,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
              ],
            )
          : _buildPlaceholderImage(context),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 200,
      width: double.infinity,
      color: colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Image non disponible',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: menu.disponible 
            ? colorScheme.secondaryContainer 
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            menu.disponible ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: menu.disponible 
                ? colorScheme.onSecondaryContainer 
                : colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            menu.disponible ? 'Disponible' : 'Indisponible',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: menu.disponible 
                  ? colorScheme.onSecondaryContainer 
                  : colorScheme.onErrorContainer,
            ),
          ),
        ],
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