import 'package:flutter/material.dart';

class WaterEntryCard extends StatelessWidget {
  final double volume;
  final String formattedTime;
  final VoidCallback onDelete;
  final String drinkType;

  const WaterEntryCard({
    required this.volume,
    required this.formattedTime,
    required this.onDelete,
    this.drinkType = 'water',
  });

  Color _getDrinkColor(String drink) {
    switch (drink) {
      case 'water':
        return Colors.blue;
      case 'tea':
        return Colors.amber;
      case 'coffee':
        return Colors.brown;
      case 'juice':
        return Colors.orange;
      case 'soda':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  IconData _getDrinkIcon(String drink) {
    switch (drink) {
      case 'water':
        return Icons.water_drop;
      case 'tea':
        return Icons.local_cafe;
      case 'coffee':
        return Icons.coffee;
      case 'juice':
        return Icons.local_drink;
      case 'soda':
        return Icons.local_drink;
      default:
        return Icons.local_drink;
    }
  }

  String _getDrinkLabel(String drink) {
    return '${drink[0].toUpperCase()}${drink.substring(1)} Intake';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDrinkColor(drinkType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getDrinkIcon(drinkType), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDrinkLabel(drinkType),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${volume.toStringAsFixed(0)} ml',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
