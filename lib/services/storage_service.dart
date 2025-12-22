import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';
import '../models/daily_summary.dart';

class StorageService {
  static const String foodEntriesKey = 'food_entries';
  static const String waterEntriesKey = 'water_entries';
  static const String dailySummaryKey = 'daily_summary';

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
}
