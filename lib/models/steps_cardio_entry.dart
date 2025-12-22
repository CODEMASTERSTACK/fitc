class StepsCardioEntry {
  final DateTime date;
  final int steps;
  final int cardioMinutes;

  StepsCardioEntry({
    required this.date,
    required this.steps,
    required this.cardioMinutes,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'steps': steps,
    'cardioMinutes': cardioMinutes,
  };

  factory StepsCardioEntry.fromJson(Map<String, dynamic> json) =>
      StepsCardioEntry(
        date: DateTime.parse(json['date']),
        steps: json['steps'] ?? 0,
        cardioMinutes: json['cardioMinutes'] ?? 0,
      );
}
