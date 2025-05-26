import 'package:flutter/material.dart';

class GenericReservationFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const GenericReservationFilterChips({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'tous', 'label': 'Toutes', 'icon': Icons.list},
      {'key': 'en attente', 'label': 'En attente', 'icon': Icons.hourglass_empty},
      {'key': 'acceptée', 'label': 'Acceptées', 'icon': Icons.check_circle},
      {'key': 'refusée', 'label': 'Refusées', 'icon': Icons.cancel},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter['key'];
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: isSelected 
                          ? Colors.white 
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                onSelected: (selected) {
                  if (selected) {
                    onFilterChanged(filter['key'] as String);
                  }
                },
                selectedColor: const Color(0xFF2E3440),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFF2E3440) 
                      : Theme.of(context).colorScheme.primary,
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
  }
} 