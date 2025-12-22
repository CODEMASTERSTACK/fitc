import 'package:intl/intl.dart';

class WaterEntry {
  final String id;
  final double volume; // in milliliters
  final DateTime timestamp;
  final String drinkType; // 'water', 'tea', 'coffee', 'juice', 'soda', 'other'

  WaterEntry({
    required this.id,
    required this.volume,
    required this.timestamp,
    this.drinkType = 'water',
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volume': volume,
      'timestamp': timestamp.toIso8601String(),
      'drinkType': drinkType,
    };
  }

  // Create from JSON
  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'],
      volume: json['volume'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      drinkType: json['drinkType'] ?? 'water',
    );
  }

  String get formattedTime => DateFormat('hh:mm a').format(timestamp);
}
