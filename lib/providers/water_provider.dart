import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/water_entry.dart';
import '../services/storage_service.dart';

class WaterProvider extends ChangeNotifier {
  final StorageService storageService;
  List<WaterEntry> _waterEntries = [];
  DateTime _selectedDate = DateTime.now();
  double dailyGoal = 3000; // 3 liters in milliliters

  WaterProvider(this.storageService);

  List<WaterEntry> get waterEntries => _waterEntries;
  DateTime get selectedDate => _selectedDate;

  List<WaterEntry> get todaysWater => _waterEntries
      .where((e) => _isSameDay(e.timestamp, _selectedDate))
      .toList();

  // Only water counts towards the daily goal
  double get totalWaterToday => todaysWater
      .where((e) => e.drinkType == 'water')
      .fold(0, (sum, e) => sum + e.volume);

  // All liquids for today
  double get totalLiquidsToday =>
      todaysWater.fold(0, (sum, e) => sum + e.volume);

  Future<void> init() async {
    _waterEntries = await storageService.getWaterEntries();
    notifyListeners();
  }

  Future<void> addWaterEntry(double volume) async {
    const uuid = Uuid();
    final entry = WaterEntry(
      id: uuid.v4(),
      volume: volume,
      timestamp: DateTime.now(),
      drinkType:
          'water', // Default to water, will be overridden in water_screen
    );

    _waterEntries.add(entry);
    await storageService.addWaterEntry(entry);
    notifyListeners();
  }

  Future<void> addLiquidEntry(double volume, String drinkType) async {
    const uuid = Uuid();
    final entry = WaterEntry(
      id: uuid.v4(),
      volume: volume,
      timestamp: DateTime.now(),
      drinkType: drinkType,
    );

    _waterEntries.add(entry);
    await storageService.addWaterEntry(entry);
    notifyListeners();
  }

  Future<void> deleteWaterEntry(String id) async {
    _waterEntries.removeWhere((entry) => entry.id == id);
    await storageService.deleteWaterEntry(id);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDailyGoal(double goal) {
    dailyGoal = goal;
    notifyListeners();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
