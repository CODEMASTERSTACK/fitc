import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/water_provider.dart';
import '../providers/exercise_provider.dart';
import '../widgets/add_exercise_dialog.dart';
import '../widgets/self_check_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_screen.dart';
import 'water_screen.dart';
import 'exercise_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _selfCheckShown = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        Provider.of<FoodProvider>(context, listen: false).setSelectedDate(today);
      } catch (_) {}
      try {
        Provider.of<WaterProvider>(context, listen: false).setSelectedDate(today);
      } catch (_) {}
      await _maybeShowSelfCheckDialog();
    });
  }

  Future<void> _maybeShowSelfCheckDialog() async {
    final now = DateTime.now();
    if (now.hour < 20 || now.hour >= 24) return; // Only after 8PM, before midnight
    final prefs = await SharedPreferences.getInstance();
    final todayKey = 'self_check_${now.year}_${now.month}_${now.day}';
    final alreadyChecked = prefs.getBool(todayKey) ?? false;
    if (!alreadyChecked && !_selfCheckShown) {
      _selfCheckShown = true;
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => SelfCheckDialog(
          onSaved: () {
            setState(() {});
          },
        ),
      );
    }
  }
  

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboard(BuildContext context) {
    final now = DateTime.now();
    String getGreeting() {
      final hour = now.hour;
      if (hour >= 5 && hour < 12) return 'Good morning';
      if (hour >= 12 && hour < 17) return 'Good afternoon';
      if (hour >= 17 && hour < 21) return 'Good evening';
      return 'Good night';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic greeting and date (profile icon removed)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${now.day}/${now.month}/${now.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Food Section
          Consumer<FoodProvider>(
            builder: (context, foodProvider, _) {
              final totalQuantity = foodProvider.todaysFoods.fold<double>(
                0,
                (sum, f) => sum + (f.quantity ?? 0),
              );
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Colors.deepPurple,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Food',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            foodProvider.totalCalories.toStringAsFixed(0),
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'kcal',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            totalQuantity.toStringAsFixed(0),
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'g/ml',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Liquid Section
          Consumer<WaterProvider>(
            builder: (context, waterProvider, _) {
              final drinks = waterProvider.todaysWater;
              final totalWater = drinks
                  .where((w) => w.drinkType == 'water')
                  .fold<double>(0, (sum, w) => sum + w.volume);

              // Group by drinkType except water
              final Map<String, int> drinkCounts = {};
              for (var w in drinks) {
                if (w.drinkType != 'water') {
                  drinkCounts[w.drinkType] =
                      (drinkCounts[w.drinkType] ?? 0) + 1;
                }
              }
              // Only show up to 3 types
              final drinkTypesToShow = drinkCounts.keys.take(3).toList();
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'Liquid',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            totalWater.toStringAsFixed(0),
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ml water',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < drinkTypesToShow.length; i++) ...[
                            Text(
                              drinkCounts[drinkTypesToShow[i]].toString(),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              drinkTypesToShow[i],
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            if (i != drinkTypesToShow.length - 1)
                              const SizedBox(width: 24),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Exercise Section
          Consumer<ExerciseProvider>(
            builder: (context, exerciseProvider, _) {
              final done = exerciseProvider.completedExercisesCount;
              final total = exerciseProvider.totalExercisesCount;
              final left = (total - done).clamp(0, total);
              final totalTime = exerciseProvider.exercisesForSelectedDay
                  .fold<int>(0, (sum, e) => sum + (e.durationSeconds ?? 0));
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Exercise',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            '$done',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'done',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '$left',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'left',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '${Duration(seconds: totalTime).inMinutes}',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'min',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Removed duplicate ExerciseProvider Consumer and dead code

          // Water compact progress
          Consumer<WaterProvider>(
            builder: (context, waterProvider, _) {
              final progress =
                  (waterProvider.totalWaterToday / waterProvider.dailyGoal)
                      .clamp(0.0, 1.0);
              return _ProgressCard(
                title: 'Water Progress',
                value:
                    '${waterProvider.totalWaterToday.toStringAsFixed(0)} / ${waterProvider.dailyGoal.toStringAsFixed(0)} ml',
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
              Text(
                'Recent Today',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
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
              final recentWater = waterProv.todaysWater.reversed
                  .take(3)
                  .toList();
              final recentEx = exProv.exercisesForSelectedDay.reversed
                  .take(3)
                  .toList();

              return Column(
                children: [
                  // Food small list
                  if (recentFood.isNotEmpty)
                    ...recentFood.map(
                      (f) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.withOpacity(0.12),
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(
                          f.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${f.calories.toStringAsFixed(0)} kcal • ${f.formattedTime}',
                        ),
                      ),
                    ),

                  // Water small list
                  if (recentWater.isNotEmpty)
                    ...recentWater.map(
                      (w) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.12),
                          child: Icon(Icons.water_drop, color: Colors.blue),
                        ),
                        title: Text(
                          '${w.volume.toStringAsFixed(0)} ml',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(w.formattedTime),
                      ),
                    ),

                  // Exercise small list
                  if (recentEx.isNotEmpty)
                    ...recentEx.map(
                      (e) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.12),
                          child: Icon(
                            Icons.fitness_center,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          e.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(e.description),
                      ),
                    ),
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

class _SmallCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _SmallCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_SmallCard> createState() => _SmallCardState();
}

class _SmallCardState extends State<_SmallCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Kick off a small entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted) setState(() => _visible = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
      fontSize: 12,
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 360),
      opacity: _visible ? 1 : 0,
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 360),
        scale: _visible ? 1 : 0.985,
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.value, style: valueStyle),
                      const SizedBox(height: 4),
                      Text(widget.subtitle, style: subtitleStyle),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatefulWidget {
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
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 70), () {
        if (mounted) setState(() => _visible = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final valueStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 380),
      opacity: _visible ? 1 : 0,
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 380),
        scale: _visible ? 1 : 0.987,
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.title, style: titleStyle),
                      Text(widget.value, style: valueStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      minHeight: 10,
                      backgroundColor: widget.color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
