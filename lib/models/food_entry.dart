import 'package:intl/intl.dart';

class FoodEntry {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double quantity; // in grams
  final DateTime timestamp;
  final String mealType; // breakfast, lunch, dinner, snack

  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.quantity,
    required this.timestamp,
    required this.mealType,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
      'mealType': mealType,
    };
  }

  // Create from JSON
  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'],
      name: json['name'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      quantity: json['quantity'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      mealType: json['mealType'],
    );
  }

  String get formattedTime => DateFormat('hh:mm a').format(timestamp);
}
