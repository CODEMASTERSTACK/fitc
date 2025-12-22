class Exercise {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // URL or path to image/video
  final int durationSeconds; // Target duration in seconds
  final String dayOfWeek; // 'Monday', 'Tuesday', etc.
  bool isCompleted;
  int actualDurationSeconds; // Actual time spent

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.durationSeconds,
    required this.dayOfWeek,
    this.isCompleted = false,
    this.actualDurationSeconds = 0,
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
}
