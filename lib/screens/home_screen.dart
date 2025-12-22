import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/water_provider.dart';
import '../widgets/food_entry_card.dart';
import '../widgets/nutrition_progress_bar.dart';
import 'food_screen.dart';
import 'water_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Daily Summary Card
            Consumer<FoodProvider>(
              builder: (context, foodProvider, _) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(
                            label: 'Calories',
                            value: foodProvider.totalCalories.toStringAsFixed(
                              0,
                            ),
                            unit: 'kcal',
                          ),
                          _SummaryItem(
                            label: 'Protein',
                            value: foodProvider.totalProtein.toStringAsFixed(1),
                            unit: 'g',
                          ),
                          _SummaryItem(
                            label: 'Carbs',
                            value: foodProvider.totalCarbs.toStringAsFixed(1),
                            unit: 'g',
                          ),
                          _SummaryItem(
                            label: 'Fats',
                            value: foodProvider.totalFats.toStringAsFixed(1),
                            unit: 'g',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Water Progress
            Consumer<WaterProvider>(
              builder: (context, waterProvider, _) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Water Intake',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${waterProvider.totalWaterToday.toStringAsFixed(0)}ml / ${waterProvider.dailyGoal.toStringAsFixed(0)}ml',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              (waterProvider.totalWaterToday /
                                      waterProvider.dailyGoal)
                                  .clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FoodScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Add Food'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WaterScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.water_drop),
                      label: const Text('Add Water'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Food Entries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Food',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Consumer<FoodProvider>(
              builder: (context, foodProvider, _) {
                if (foodProvider.todaysFoods.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No food entries yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foodProvider.todaysFoods.length,
                  itemBuilder: (context, index) {
                    final food = foodProvider.todaysFoods[index];
                    return FoodEntryCard(
                      name: food.name,
                      calories: food.calories,
                      mealType: food.mealType,
                      formattedTime: food.formattedTime,
                      onDelete: () {
                        foodProvider.deleteFoodEntry(food.id);
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
