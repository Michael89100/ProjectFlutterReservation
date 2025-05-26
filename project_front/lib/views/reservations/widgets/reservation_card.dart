import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/reservation.dart';
import 'reservation_action_dialog.dart';

extension DateTimeExtension on DateTime {
  String get frenchDayName {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days[weekday - 1];
  }
}

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final Function(String id, String? comment) onAccept;
  final Function(String id, String? comment) onRefuse;

  const ReservationCard({
    Key? key,
    required this.reservation,
    required this.onAccept,
    required this.onRefuse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
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
              Colors.grey[700]!,
              Colors.grey[800]!,
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${reservation.prenom ?? ''} ${reservation.nom}'.trim(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                reservation.telephone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.people,
                      'Nombre de couverts',
                      '${reservation.nombreCouverts} personne${reservation.nombreCouverts > 1 ? 's' : ''}',
                    ),
                    if (reservation.horaire != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date',
                        '${reservation.horaire!.frenchDayName} ${DateFormat('dd/MM/yyyy').format(reservation.horaire!)}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.access_time,
                        'Heure',
                        DateFormat('HH:mm').format(reservation.horaire!),
                      ),
                    ],
                    if (reservation.createdAt != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.schedule,
                        'Demande créée le',
                        DateFormat('dd/MM/yyyy à HH:mm').format(reservation.createdAt!),
                      ),
                    ],
                  ],
                ),
              ),

              // Commentaire s'il existe
              if (reservation.commentaire != null && reservation.commentaire!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.comment,
                            color: Colors.blue[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Commentaire',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reservation.commentaire!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Boutons d'action (seulement pour les réservations en attente)
              if (reservation.status == 'en attente') ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showActionDialog(context, true),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accepter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showActionDialog(context, false),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Refuser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[300],
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
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showActionDialog(BuildContext context, bool isAccept) {
    print('Action dialog pour réservation ID: ${reservation.id}');
    
    if (reservation.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: ID de réservation manquant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => ReservationActionDialog(
        reservation: reservation,
        isAccept: isAccept,
        onConfirm: (comment) {
          print('Confirmation action: ${isAccept ? 'accepter' : 'refuser'} réservation ${reservation.id}');
          if (isAccept) {
            onAccept(reservation.id!, comment);
          } else {
            onRefuse(reservation.id!, comment);
          }
        },
      ),
    );
  }
} 