import '../models/steps_cardio_entry.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';
import '../models/daily_summary.dart';
import '../models/exercise.dart';

class StorageService {
  static const String stepsCardioKey = 'steps_cardio_entries';

  // Steps & Cardio Methods
  Future<void> saveStepsCardioEntry(StepsCardioEntry entry) async {
    final entries = await getAllStepsCardioEntries();
    entries.removeWhere((e) => _isSameDay(e.date, entry.date));
    entries.add(entry);
    await _saveStepsCardioEntries(entries);
  }

  Future<StepsCardioEntry?> getStepsCardioEntryForDate(DateTime date) async {
    final entries = await getAllStepsCardioEntries();
    try {
      return entries.firstWhere((e) => _isSameDay(e.date, date));
    } catch (_) {
      return null;
    }
  }

  Future<List<StepsCardioEntry>> getAllStepsCardioEntries() async {
    final jsonString = _prefs.getString(stepsCardioKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((item) => StepsCardioEntry.fromJson(item)).toList();
  }

  Future<void> _saveStepsCardioEntries(List<StepsCardioEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(stepsCardioKey, jsonEncode(jsonList));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static const String foodEntriesKey = 'food_entries';
  static const String waterEntriesKey = 'water_entries';
  static const String dailySummaryKey = 'daily_summary';
  static const String exercisesKey = 'exercises';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Food Entry Methods
  Future<void> addFoodEntry(FoodEntry entry) async {
    final entries = await getFoodEntries();
    entries.add(entry);
    await _saveFoodEntries(entries);
  }

  Future<List<FoodEntry>> getFoodEntries() async {
    final jsonString = _prefs.getString(foodEntriesKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((item) => FoodEntry.fromJson(item)).toList();
  }

  Future<void> deleteFoodEntry(String id) async {
    final entries = await getFoodEntries();
    entries.removeWhere((entry) => entry.id == id);
    await _saveFoodEntries(entries);
  }

  Future<void> _saveFoodEntries(List<FoodEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(foodEntriesKey, jsonEncode(jsonList));
  }

  // Water Entry Methods
  Future<void> addWaterEntry(WaterEntry entry) async {
    final entries = await getWaterEntries();
    entries.add(entry);
    await _saveWaterEntries(entries);
  }

  Future<List<WaterEntry>> getWaterEntries() async {
    final jsonString = _prefs.getString(waterEntriesKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((item) => WaterEntry.fromJson(item)).toList();
  }

  Future<void> deleteWaterEntry(String id) async {
    final entries = await getWaterEntries();
    entries.removeWhere((entry) => entry.id == id);
    await _saveWaterEntries(entries);
  }

  Future<void> _saveWaterEntries(List<WaterEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(waterEntriesKey, jsonEncode(jsonList));
  }

  // Daily Summary Methods
  Future<void> saveDailySummary(DailySummary summary) async {
    final json = summary.toJson();
    await _prefs.setString(dailySummaryKey, jsonEncode(json));
  }

  Future<DailySummary?> getDailySummary() async {
    final jsonString = _prefs.getString(dailySummaryKey);
    if (jsonString == null) return null;
    return DailySummary.fromJson(jsonDecode(jsonString));
  }

  // Get entries for a specific date
  Future<List<FoodEntry>> getFoodEntriesForDate(DateTime date) async {
    final entries = await getFoodEntries();
    return entries
        .where(
          (entry) =>
              entry.timestamp.year == date.year &&
              entry.timestamp.month == date.month &&
              entry.timestamp.day == date.day,
        )
        .toList();
  }

  Future<List<WaterEntry>> getWaterEntriesForDate(DateTime date) async {
    final entries = await getWaterEntries();
    return entries
        .where(
          (entry) =>
              entry.timestamp.year == date.year &&
              entry.timestamp.month == date.month &&
              entry.timestamp.day == date.day,
        )
        .toList();
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    await _prefs.clear();
  }

  // Exercise Methods
  Future<void> addExercise(Exercise exercise) async {
    final exercises = await getExercises();
    exercises.add(exercise);
    await _saveExercises(exercises);
  }

  Future<List<Exercise>> getExercises() async {
    final jsonString = _prefs.getString(exercisesKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((item) => Exercise.fromJson(item)).toList();
  }

  Future<void> updateExercise(Exercise exercise) async {
    final exercises = await getExercises();
    final index = exercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      exercises[index] = exercise;
      await _saveExercises(exercises);
    }
  }

  Future<void> deleteExercise(String id) async {
    final exercises = await getExercises();
    exercises.removeWhere((e) => e.id == id);
    await _saveExercises(exercises);
  }

  Future<void> _saveExercises(List<Exercise> exercises) async {
    final jsonList = exercises.map((e) => e.toJson()).toList();
    await _prefs.setString(exercisesKey, jsonEncode(jsonList));
  }
}
