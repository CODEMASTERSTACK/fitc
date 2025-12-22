import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/food_entry.dart';
import '../services/storage_service.dart';

class FoodProvider extends ChangeNotifier {
  final StorageService storageService;
  List<FoodEntry> _foodEntries = [];
  DateTime _selectedDate = DateTime.now();

  FoodProvider(this.storageService);

  List<FoodEntry> get foodEntries => _foodEntries;
  DateTime get selectedDate => _selectedDate;

  List<FoodEntry> get todaysFoods => _foodEntries
      .where((e) => _isSameDay(e.timestamp, _selectedDate))
      .toList();

  double get totalCalories => todaysFoods.fold(0, (sum, e) => sum + e.calories);
  double get totalProtein => todaysFoods.fold(0, (sum, e) => sum + e.protein);
  double get totalCarbs => todaysFoods.fold(0, (sum, e) => sum + e.carbs);
  double get totalFats => todaysFoods.fold(0, (sum, e) => sum + e.fats);

  Future<void> init() async {
    _foodEntries = await storageService.getFoodEntries();
    notifyListeners();
  }

  Future<void> addFoodEntry({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required double quantity,
    required String mealType,
  }) async {
    const uuid = Uuid();
    final entry = FoodEntry(
      id: uuid.v4(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      quantity: quantity,
      timestamp: DateTime.now(),
      mealType: mealType,
    );

    _foodEntries.add(entry);
    await storageService.addFoodEntry(entry);
    notifyListeners();
  }

  Future<void> deleteFoodEntry(String id) async {
    _foodEntries.removeWhere((entry) => entry.id == id);
    await storageService.deleteFoodEntry(id);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
