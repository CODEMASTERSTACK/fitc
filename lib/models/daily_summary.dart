class DailySummary {
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final double totalWater; // in milliliters
  final int foodEntryCount;
  final int waterEntryCount;

  DailySummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.totalWater,
    required this.foodEntryCount,
    required this.waterEntryCount,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'totalWater': totalWater,
      'foodEntryCount': foodEntryCount,
      'waterEntryCount': waterEntryCount,
    };
  }

  // Create from JSON
  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse(json['date']),
      totalCalories: json['totalCalories'].toDouble(),
      totalProtein: json['totalProtein'].toDouble(),
      totalCarbs: json['totalCarbs'].toDouble(),
      totalFats: json['totalFats'].toDouble(),
      totalWater: json['totalWater'].toDouble(),
      foodEntryCount: json['foodEntryCount'],
      waterEntryCount: json['waterEntryCount'],
    );
  }
}
