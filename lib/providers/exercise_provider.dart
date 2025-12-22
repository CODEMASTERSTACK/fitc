import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../services/storage_service.dart';

class ExerciseProvider extends ChangeNotifier {
  final StorageService storageService;
  List<Exercise> _exercises = [];
  String _selectedDay = 'Monday';

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  ExerciseProvider(this.storageService);

  List<Exercise> get allExercises => _exercises;
  String get selectedDay => _selectedDay;

  List<Exercise> get exercisesForSelectedDay =>
      _exercises.where((e) => e.dayOfWeek == _selectedDay).toList();

  int get completedExercisesCount =>
      exercisesForSelectedDay.where((e) => e.isCompleted).length;

  int get totalExercisesCount => exercisesForSelectedDay.length;

  Future<void> init() async {
    _exercises = await storageService.getExercises();
    notifyListeners();
  }

  Future<void> addExercise({
    required String name,
    required String description,
    required String imageUrl,
    required int durationSeconds,
    required String dayOfWeek,
  }) async {
    const uuid = Uuid();
    final exercise = Exercise(
      id: uuid.v4(),
      name: name,
      description: description,
      imageUrl: imageUrl,
      durationSeconds: durationSeconds,
      dayOfWeek: dayOfWeek,
    );

    _exercises.add(exercise);
    await storageService.addExercise(exercise);
    notifyListeners();
  }

  Future<void> updateExercise(Exercise exercise) async {
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _exercises[index] = exercise;
      await storageService.updateExercise(exercise);
      notifyListeners();
    }
  }

  Future<void> deleteExercise(String id) async {
    _exercises.removeWhere((e) => e.id == id);
    await storageService.deleteExercise(id);
    notifyListeners();
  }

  void setSelectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> markExerciseComplete(String id, int actualDurationSeconds) async {
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      _exercises[index].isCompleted = true;
      _exercises[index].actualDurationSeconds = actualDurationSeconds;
      await updateExercise(_exercises[index]);
    }
  }

  Future<void> resetExerciseProgress(String id) async {
    final index = _exercises.indexWhere((e) => e.id == id);
    if (index != -1) {
      _exercises[index].isCompleted = false;
      _exercises[index].actualDurationSeconds = 0;
      await updateExercise(_exercises[index]);
    }
  }
}
