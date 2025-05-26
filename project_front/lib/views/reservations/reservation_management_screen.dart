import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/reservation_management_viewmodel.dart';
import '../../models/reservation.dart';
import 'widgets/reservation_card.dart';
import 'widgets/reservation_stats.dart';
import 'widgets/reservation_filter_chips.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReservationManagementScreen> createState() => _ReservationManagementScreenState();
}

class _ReservationManagementScreenState extends State<ReservationManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationManagementViewModel>().loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestion des Réservations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E3440),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<ReservationManagementViewModel>(
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
      body: Consumer<ReservationManagementViewModel>(
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
                    child: const ReservationStats(),
                  ),
                ),

                // Filtres
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: const ReservationFilterChips(),
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
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final reservation = viewModel.reservations[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ReservationCard(
                              reservation: reservation,
                              onAccept: (id, comment) => _handleAccept(viewModel, id, comment),
                              onRefuse: (id, comment) => _handleRefuse(viewModel, id, comment),
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

  Widget _buildErrorWidget(ReservationManagementViewModel viewModel) {
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

  Widget _buildEmptyState(ReservationManagementViewModel viewModel) {
    String message;
    IconData icon;

    switch (viewModel.selectedFilter) {
      case 'en_attente':
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

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
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
              'Les nouvelles réservations apparaîtront ici',
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

  Future<void> _handleAccept(ReservationManagementViewModel viewModel, String id, String? comment) async {
    final success = await viewModel.acceptReservation(id, commentaire: comment);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Réservation acceptée avec succès'),
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
  }

  Future<void> _handleRefuse(ReservationManagementViewModel viewModel, String id, String? comment) async {
    final success = await viewModel.refuseReservation(id, commentaire: comment);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 8),
              Text('Réservation refusée'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
} 