import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/reservation_management_viewmodel.dart';

class ReservationFilterChips extends StatelessWidget {
  final ReservationManagementViewModel? viewModel;

  const ReservationFilterChips({
    Key? key,
    this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationManagementViewModel>(
      builder: (context, vm, child) {
        final actualViewModel = viewModel ?? vm;
        
        final filters = [
          {'key': 'tous', 'label': 'Toutes', 'icon': Icons.list},
          {'key': 'en attente', 'label': 'En attente', 'icon': Icons.hourglass_empty},
          {'key': 'acceptée', 'label': 'Acceptées', 'icon': Icons.check_circle},
          {'key': 'refusée', 'label': 'Refusées', 'icon': Icons.cancel},
        ];

        return Container(
          height: 50, // Hauteur fixe pour éviter l'overflow
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isSelected = actualViewModel.selectedFilter == filter['key'];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'] as IconData,
                          size: 14,
                          color: isSelected ? Colors.white : const Color(0xFF2E3440),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filter['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : const Color(0xFF2E3440),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        actualViewModel.filterReservations(filter['key'] as String);
                      }
                    },
                    selectedColor: const Color(0xFF2E3440),
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF2E3440) : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    elevation: isSelected ? 4 : 1,
                    shadowColor: Colors.black.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
} 