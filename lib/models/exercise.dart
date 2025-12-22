class Exercise {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // URL or path to image/video
  final int durationSeconds; // Target duration in seconds
  final String dayOfWeek; // 'Monday', 'Tuesday', etc.
  bool isCompleted;
  int actualDurationSeconds; // Actual time spent
  int actualReps; // Actual reps completed (for rep-based exercises)

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.durationSeconds,
    required this.dayOfWeek,
    this.isCompleted = false,
    this.actualDurationSeconds = 0,
    this.actualReps = 0,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
      'dayOfWeek': dayOfWeek,
      'isCompleted': isCompleted,
      'actualDurationSeconds': actualDurationSeconds,
      'actualReps': actualReps,
    };
  }

  // Create from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      durationSeconds: json['durationSeconds'],
      dayOfWeek: json['dayOfWeek'],
      isCompleted: json['isCompleted'] ?? false,
      actualDurationSeconds: json['actualDurationSeconds'] ?? 0,
      actualReps: json['actualReps'] ?? 0,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedActualDuration {
    final minutes = actualDurationSeconds ~/ 60;
    final seconds = actualDurationSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedActualReps => '$actualReps reps';

  String get formattedActualDisplay {
    if (actualReps > 0) return formattedActualReps;
    if (actualDurationSeconds > 0) return formattedActualDuration;
    return '0';
  }
}
