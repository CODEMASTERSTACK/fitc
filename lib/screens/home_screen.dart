import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/water_provider.dart';
import '../providers/exercise_provider.dart';
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
    final dateStr = DateTime.now();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateStr.day}/${dateStr.month}/${dateStr.year}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
              )
            ],
          ),

          const SizedBox(height: 18),

          // Summary cards row
          Row(
            children: [
              Expanded(
                child: Consumer<FoodProvider>(
                  builder: (context, foodProvider, _) => _SmallCard(
                    title: 'Food',
                    value: foodProvider.totalCalories.toStringAsFixed(0),
                    subtitle: 'kcal today',
                    icon: Icons.restaurant,
                    color: Colors.deepPurple,
                    onTap: () => _onItemTapped(1),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<WaterProvider>(
                  builder: (context, waterProvider, _) => _SmallCard(
                    title: 'Liquid',
                    value: waterProvider.totalWaterToday.toStringAsFixed(0),
                    subtitle: 'ml today',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    onTap: () => _onItemTapped(2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<ExerciseProvider>(
                  builder: (context, exerciseProvider, _) => _SmallCard(
                    title: 'Exercise',
                    value: '${exerciseProvider.completedExercisesCount}/${exerciseProvider.totalExercisesCount}',
                    subtitle: 'done today',
                    icon: Icons.fitness_center,
                    color: Colors.green,
                    onTap: () => _onItemTapped(3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Water compact progress
          Consumer<WaterProvider>(
            builder: (context, waterProvider, _) {
              final progress = (waterProvider.totalWaterToday / waterProvider.dailyGoal).clamp(0.0, 1.0);
              return _ProgressCard(
                title: 'Water Progress',
                value: '${waterProvider.totalWaterToday.toStringAsFixed(0)} / ${waterProvider.dailyGoal.toStringAsFixed(0)} ml',
                progress: progress,
                color: Colors.blue,
                onTap: () => _onItemTapped(2),
              );
            },
          ),

          const SizedBox(height: 16),

          // Recent items header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Today', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => _onItemTapped(1),
                child: const Text('View all'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Recent rows: Food (3 items), Liquid (3 items), Exercise (3 items)
          Consumer3<FoodProvider, WaterProvider, ExerciseProvider>(
            builder: (context, foodProv, waterProv, exProv, _) {
              final recentFood = foodProv.todaysFoods.reversed.take(3).toList();
              final recentWater = waterProv.todaysWater.reversed.take(3).toList();
              final recentEx = exProv.exercisesForSelectedDay.reversed.take(3).toList();

              return Column(
                children: [
                  // Food small list
                  if (recentFood.isNotEmpty)
                    ...recentFood.map((f) => ListTile(
                          dense: true,
                          leading: CircleAvatar(backgroundColor: Colors.deepPurple.withOpacity(0.12), child: Icon(Icons.restaurant, color: Colors.deepPurple)),
                          title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${f.calories.toStringAsFixed(0)} kcal • ${f.formattedTime}'),
                        )),

                  // Water small list
                  if (recentWater.isNotEmpty)
                    ...recentWater.map((w) => ListTile(
                          dense: true,
                          leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.12), child: Icon(Icons.water_drop, color: Colors.blue)),
                          title: Text('${w.volume.toStringAsFixed(0)} ml', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(w.formattedTime),
                        )),

                  // Exercise small list
                  if (recentEx.isNotEmpty)
                    ...recentEx.map((e) => ListTile(
                          dense: true,
                          leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.12), child: Icon(Icons.fitness_center, color: Colors.green)),
                          title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(e.description),
                        )),
                ],
              );
            },
          ),

          const SizedBox(height: 40),
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
                label: 'Liquid',
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



class _SmallCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const _ProgressCard({
    Key? key,
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
