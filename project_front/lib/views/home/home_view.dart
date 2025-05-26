import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../components/menu_card.dart';
import '../../services/reservation_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final LatLng _restaurantPosition = const LatLng(48.8566, 2.3522);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuViewModel>().loadMenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      drawer: _buildNavigationDrawer(context),
      body: CustomScrollView(
        slivers: [
          // En-tête avec image de fond
          SliverAppBar(
            expandedHeight: size.height * 0.45,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de fond avec effet de parallaxe
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.darken,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Contenu du header
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo ou nom du restaurant
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Le Petit Bistrot',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cuisine française authentique',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Une expérience culinaire unique dans un cadre chaleureux',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Badge de notation
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8/5',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(250+ avis)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Bienvenue
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Bienvenue',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Découvrez une expérience culinaire unique dans un cadre chaleureux et convivial. Notre chef vous propose une cuisine raffinée aux saveurs authentiques.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Carte
                  Text(
                    'Notre Restaurant',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _restaurantPosition,
                          zoom: 15,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('restaurant'),
                            position: _restaurantPosition,
                            infoWindow: const InfoWindow(
                              title: 'Le Petit Bistrot',
                              snippet: 'Cuisine française authentique',
                            ),
                          ),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Plats du jour
                  Text(
                    'Nos Plats du Jour',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<MenuViewModel>(
                    builder: (context, menuViewModel, child) {
                      if (menuViewModel.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final featuredDishes = menuViewModel.availableMenus.take(3).toList();
                      
                      return Column(
                        children: [
                          ...featuredDishes.map((menu) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDishCard(context, menu),
                          )),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/menu'),
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('Voir toute la carte'),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Horaires et Contact dans une grille
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildInfoCard(
                        context,
                        'Horaires',
                        Icons.access_time,
                        [
                          'Lun-Ven: 12h-14h30',
                          '19h-22h30',
                          'Sam-Dim: 12h-23h',
                        ],
                        colorScheme.secondaryContainer,
                      ),
                      _buildInfoCard(
                        context,
                        'Contact',
                        Icons.phone,
                        [
                          '+33 1 23 45 67 89',
                          'contact@lepetitbistrot.fr',
                          '123 Rue de la Paix',
                        ],
                        colorScheme.tertiaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return Column(
                        children: [
                          _buildActionButton(
                            context,
                            'Voir notre carte',
                            Icons.restaurant_menu,
                            colorScheme.primary,
                            () => Navigator.of(context).pushNamed('/menu'),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            context,
                            'Réserver une table',
                            Icons.event_seat,
                            colorScheme.secondary,
                            () {
                              _showReservationForm(context);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, menu) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du plat
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                menu.image_url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
          // Informations du plat
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        menu.nom,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${menu.prix.toStringAsFixed(2)} €',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  menu.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<String> details,
    Color backgroundColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color backgroundColor,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          backgroundColor: backgroundColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showReservationForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    DateTime selectedDate = DateTime.now();
    String? selectedSlot; // Ajout pour le créneau sélectionné
    int numberOfGuests = 2;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    // Champs pour non connecté
    final TextEditingController nomController = TextEditingController();
    final TextEditingController prenomController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController telephoneController = TextEditingController();

    Future<List<Map<String, dynamic>>> _fetchAvailableSlots(DateTime date) async {
      final response = await ReservationService.instance.getAvailableSlots(date);
      return response;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle pour le drag
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        'Réserver une table',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nombre de couverts
                      Text(
                        'Nombre de couverts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: numberOfGuests > 1
                                  ? () => setState(() => numberOfGuests--)
                                  : null,
                              icon: Icon(
                                Icons.remove,
                                color: numberOfGuests > 1
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '$numberOfGuests',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: numberOfGuests < 10
                                  ? () => setState(() => numberOfGuests++)
                                  : null,
                              icon: Icon(
                                Icons.add,
                                color: numberOfGuests < 10
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: colorScheme,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                              selectedSlot = null; // Réinitialise le créneau sélectionné
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Heure (créneau)
                      Text(
                        'Créneau',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchAvailableSlots(selectedDate),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('Erreur lors du chargement des créneaux');
                          }
                          final slots = snapshot.data ?? [];
                          if (slots.isEmpty) {
                            return Text('Aucun créneau disponible');
                          }
                          // Correction : filtrer les doublons d'heures
                          final uniqueSlots = <String, Map<String, dynamic>>{};
                          for (final slot in slots) {
                            final heure = slot['heure'] as String;
                            if (!uniqueSlots.containsKey(heure)) {
                              uniqueSlots[heure] = slot;
                            }
                          }
                          return DropdownButtonFormField<String>(
                            value: selectedSlot,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceVariant,
                            ),
                            items: uniqueSlots.values.map((slot) {
                              final heure = slot['heure'] as String;
                              final places = slot['places_disponibles'] ?? 20;
                              return DropdownMenuItem<String>(
                                value: heure,
                                child: Text('$heure'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedSlot = value);
                            },
                            hint: const Text('Sélectionnez un créneau'),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Si non connecté, afficher les champs d'identité
                      if (!authViewModel.isAuthenticated) ...[
                        Text('Nom', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nomController,
                          decoration: const InputDecoration(hintText: 'Votre nom'),
                        ),
                        const SizedBox(height: 12),
                        Text('Prénom', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: prenomController,
                          decoration: const InputDecoration(hintText: 'Votre prénom'),
                        ),
                        const SizedBox(height: 12),
                        Text('Email', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(hintText: 'Votre email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        Text('Téléphone', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: telephoneController,
                          decoration: const InputDecoration(hintText: 'Votre téléphone'),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Bouton de confirmation
                      FilledButton.icon(
                        onPressed: () async {
                          if (selectedSlot == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez sélectionner un créneau.'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          final String heure = selectedSlot!;
                          bool reservationSuccess = false;
                          if (authViewModel.isAuthenticated) {
                            reservationSuccess = await ReservationService.instance.createReservation(
                              token: authViewModel.token,
                              userId: authViewModel.currentUser?.id,
                              nombreCouverts: numberOfGuests,
                              date: selectedDate,
                              heure: heure,
                            );
                          } else {
                            if (nomController.text.isEmpty || prenomController.text.isEmpty || emailController.text.isEmpty || telephoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veuillez remplir tous les champs.'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            reservationSuccess = await ReservationService.instance.createReservation(
                              nombreCouverts: numberOfGuests,
                              date: selectedDate,
                              heure: heure,
                              nom: nomController.text,
                              prenom: prenomController.text,
                              email: emailController.text,
                              telephone: telephoneController.text,
                            );
                          }
                          if (reservationSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Réservation enregistrée !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erreur lors de la réservation'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmer la réservation'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Drawer(
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;
          
          return Column(
            children: [
              // En-tête du drawer
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 35,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (user != null) ...[
                          Text(
                            user.nom,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Invité',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      Icons.home,
                      'Accueil',
                      () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.restaurant_menu,
                      'Notre carte',
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/menu');
                      },
                    ),
                    
                    // Section réservations
                    if (user != null) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'RÉSERVATIONS',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Option pour les clients
                      if (user.role == 'client')
                        _buildDrawerItem(
                          context,
                          Icons.event_note,
                          'Mes réservations',
                          () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/my-reservations');
                          },
                          isHighlighted: true,
                        ),
                      
                      // Option pour les serveurs
                      if (user.role == 'serveur')
                        _buildDrawerItem(
                          context,
                          Icons.event_seat,
                          'Gestion des réservations',
                          () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/reservations');
                          },
                          isHighlighted: true,
                        ),
                    ],
                    
                    const Divider(),
                    
                    // Section utilisateur
                    if (user != null) ...[
                      _buildDrawerItem(
                        context,
                        Icons.person,
                        'Mon profil',
                        () {
                          Navigator.pop(context);
                          // TODO: Naviguer vers la page de profil
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Page de profil à venir')),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.logout,
                        'Se déconnecter',
                        () {
                          Navigator.pop(context);
                          authViewModel.logout();
                        },
                        isDestructive: true,
                      ),
                    ] else ...[
                      _buildDrawerItem(
                        context,
                        Icons.login,
                        'Se connecter',
                        () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.person_add,
                        'S\'inscrire',
                        () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/register');
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Divider(),
                    Text(
                      'Le Petit Bistrot',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isHighlighted = false,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color iconColor = colorScheme.onSurface;
    Color textColor = colorScheme.onSurface;
    Color? backgroundColor;
    
    if (isHighlighted) {
      iconColor = colorScheme.primary;
      textColor = colorScheme.primary;
      backgroundColor = colorScheme.primaryContainer.withOpacity(0.3);
    } else if (isDestructive) {
      iconColor = Colors.red[600]!;
      textColor = Colors.red[600]!;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}