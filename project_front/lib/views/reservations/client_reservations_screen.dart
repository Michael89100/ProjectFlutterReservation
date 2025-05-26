import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/client_reservations_viewmodel.dart';
import '../../models/reservation.dart';
import '../../utils/date_formatter.dart';
import 'widgets/client_reservation_card.dart';
import 'widgets/generic_reservation_stats.dart';
import 'widgets/generic_reservation_filter_chips.dart';

class ClientReservationsScreen extends StatefulWidget {
  const ClientReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ClientReservationsScreen> createState() => _ClientReservationsScreenState();
}

class _ClientReservationsScreenState extends State<ClientReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientReservationsViewModel>().loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mes Réservations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E3440),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<ClientReservationsViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: viewModel.isLoading ? null : () => viewModel.refresh(),
              );
            },
          ),
        ],
      ),
      body: Consumer<ClientReservationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.error != null) {
            return _buildErrorWidget(viewModel);
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            color: const Color(0xFF2E3440),
            child: CustomScrollView(
              slivers: [
                // Statistiques
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: GenericReservationStats(
                      totalReservations: viewModel.totalReservations,
                      pendingReservations: viewModel.pendingReservations,
                      acceptedReservations: viewModel.acceptedReservations,
                      refusedReservations: viewModel.refusedReservations,
                    ),
                  ),
                ),

                // Filtres
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: GenericReservationFilterChips(
                      selectedFilter: viewModel.selectedFilter,
                      onFilterChanged: viewModel.filterReservations,
                    ),
                  ),
                ),

                // Message d'information pour les clients
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vous pouvez modifier ou annuler vos réservations en attente.',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Liste des réservations
                if (viewModel.isLoading && viewModel.reservations.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E3440),
                      ),
                    ),
                  )
                else if (viewModel.reservations.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(viewModel),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final reservation = viewModel.reservations[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ClientReservationCard(
                              reservation: reservation,
                              onEdit: _canEditReservation(reservation)
                                  ? () => _showEditDialog(context, viewModel, reservation)
                                  : null,
                              onDelete: _canDeleteReservation(reservation)
                                  ? () => _showDeleteDialog(context, viewModel, reservation)
                                  : null,
                            ),
                          );
                        },
                        childCount: viewModel.reservations.length,
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

  Widget _buildErrorWidget(ClientReservationsViewModel viewModel) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.clearError();
                viewModel.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ClientReservationsViewModel viewModel) {
    String message;
    IconData icon;

    switch (viewModel.selectedFilter) {
      case 'en attente':
        message = 'Aucune réservation en attente';
        icon = Icons.hourglass_empty;
        break;
      case 'acceptée':
        message = 'Aucune réservation acceptée';
        icon = Icons.check_circle_outline;
        break;
      case 'refusée':
        message = 'Aucune réservation refusée';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'Aucune réservation trouvée';
        icon = Icons.event_busy;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos réservations apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: viewModel.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3440),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vérifie si une réservation peut être modifiée
  bool _canEditReservation(Reservation reservation) {
    // Ne peut pas modifier les réservations refusées
    return reservation.status != 'refusée';
  }

  /// Vérifie si une réservation peut être supprimée
  bool _canDeleteReservation(Reservation reservation) {
    // Peut supprimer les réservations en attente et acceptées
    return reservation.status == 'en attente' || reservation.status == 'acceptée';
  }

  void _showEditDialog(BuildContext context, ClientReservationsViewModel viewModel, Reservation reservation) {
    DateTime selectedDateTime = reservation.horaire ?? DateTime.now();
    int numberOfGuests = reservation.nombreCouverts;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier la réservation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sélection de la date
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  DateFormatter.formatDateFrench(selectedDateTime),
                ),
                onTap: () async {
                  final now = DateTime.now();
                  final initialDate = selectedDateTime.isBefore(now) ? now : selectedDateTime;
                  
                  final date = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: now,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('fr', 'FR'),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        selectedDateTime.hour,
                        selectedDateTime.minute,
                      );
                    });
                  }
                },
              ),
              
              // Sélection de l'heure
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure'),
                subtitle: Text(DateFormatter.formatTimeFrench(selectedDateTime)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    builder: (context, child) {
                      return Localizations.override(
                        context: context,
                        locale: const Locale('fr', 'FR'),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        selectedDateTime.year,
                        selectedDateTime.month,
                        selectedDateTime.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
              ),
              
              // Nombre de couverts
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Nombre de couverts'),
                subtitle: Text('$numberOfGuests personne${numberOfGuests > 1 ? 's' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: numberOfGuests > 1 
                          ? () => setState(() => numberOfGuests--) 
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$numberOfGuests'),
                    IconButton(
                      onPressed: numberOfGuests < 20 
                          ? () => setState(() => numberOfGuests++) 
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Vérifier si la réservation était acceptée
                final wasAccepted = reservation.status == 'acceptée';
                
                print('Date sélectionnée pour modification: $selectedDateTime');
                final success = await viewModel.updateReservation(
                  reservation.id!,
                  horaire: selectedDateTime,
                  nombreCouverts: numberOfGuests,
                );
                if (success && mounted) {
                  String message = 'Réservation modifiée avec succès';
                  if (wasAccepted) {
                    message += '\nLa réservation repasse en attente de validation.';
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text(message)),
                        ],
                      ),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ClientReservationsViewModel viewModel, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await viewModel.deleteReservation(reservation.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Réservation annulée avec succès'),
                      ],
                    ),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
} 