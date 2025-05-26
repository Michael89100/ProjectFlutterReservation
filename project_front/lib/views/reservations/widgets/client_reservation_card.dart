import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/reservation.dart';
import '../../../utils/date_formatter.dart';

extension DateTimeExtension on DateTime {
  String get frenchDayName {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days[weekday - 1];
  }
}

class ClientReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClientReservationCard({
    Key? key,
    required this.reservation,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Réservation #${reservation.id?.substring(0, 8) ?? 'N/A'}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCreatedDate(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Informations de la réservation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.person,
                      'Client',
                      '${reservation.nom}${reservation.prenom != null ? ' ${reservation.prenom}' : ''}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.phone,
                      'Téléphone',
                      reservation.telephone,
                    ),
                    if (reservation.email != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.email,
                        'Email',
                        reservation.email!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.people,
                      'Nombre de couverts',
                      '${reservation.nombreCouverts} personne${reservation.nombreCouverts > 1 ? 's' : ''}',
                    ),
                    if (reservation.horaire != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.schedule,
                        'Date et heure',
                        _formatDateTime(reservation.horaire!),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Commentaire si présent
              if (reservation.commentaire != null && reservation.commentaire!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Commentaire',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reservation.commentaire!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Actions (seulement pour les réservations non refusées)
              if (reservation.status != 'refusée') ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (onEdit != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    if (onEdit != null && onDelete != null) const SizedBox(width: 12),
                    if (onDelete != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete),
                          label: const Text('Annuler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            side: BorderSide(color: Colors.red[600]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (reservation.status) {
      case 'en attente':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.hourglass_empty;
        break;
      case 'acceptée':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case 'refusée':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            reservation.statusDisplayName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormatter.formatDateTimeFrench(dateTime);
  }

  String _formatCreatedDate() {
    if (reservation.createdAt == null) return 'Date inconnue';
    return DateFormatter.formatRelativeDate(reservation.createdAt!);
  }
} 