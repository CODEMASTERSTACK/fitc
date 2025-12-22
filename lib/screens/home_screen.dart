import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/water_provider.dart';
import '../providers/exercise_provider.dart';
import '../widgets/food_entry_card.dart';
import '../widgets/add_exercise_dialog.dart';
import 'food_screen.dart';
import 'water_screen.dart';
import 'exercise_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboard(BuildContext context) {
    return SingleChildScrollView(
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
                          value: foodProvider.totalCalories.toStringAsFixed(0),
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

          // Action Buttons -> now switch tabs instead of push
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _onItemTapped(1),
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
                    onPressed: () => _onItemTapped(2),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildDashboard(context),
      const FoodTabContent(),
      const LiquidTabContent(),
      const ExerciseTabContent(),
    ];

    final titles = ['Dashboard', 'Add Food', 'Liquid', 'Exercise'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        elevation: 0,
        centerTitle: true,
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 3
          ? FloatingActionButton(
              onPressed: () {
                final exerciseProvider = context.read<ExerciseProvider>();
                showDialog(
                  context: context,
                  builder: (context) => AddExerciseDialog(
                    selectedDay: exerciseProvider.selectedDay,
                  ),
                );
              },
              tooltip: 'Add Exercise',
              child: const Icon(Icons.add),
            )
          : null,
      // Floating minimal bottom nav
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                label: 'Home',
                selected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _NavItem(
                icon: Icons.restaurant,
                label: 'Food',
                selected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _NavItem(
                icon: Icons.water_drop,
                label: 'Water',
                selected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _NavItem(
                icon: Icons.fitness_center,
                label: 'Exercise',
                selected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey[600];
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? color!.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
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
