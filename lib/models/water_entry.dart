import 'package:intl/intl.dart';

class WaterEntry {
  final String id;
  final double volume; // in milliliters
  final DateTime timestamp;

  WaterEntry({required this.id, required this.volume, required this.timestamp});

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volume': volume,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'],
      volume: json['volume'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String get formattedTime => DateFormat('hh:mm a').format(timestamp);
}
