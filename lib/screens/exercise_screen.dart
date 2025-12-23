import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_card.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Plan'), elevation: 0),
      body: const ExerciseTabContent(),
    );
  }
}

class ExerciseTabContent extends StatefulWidget {
  const ExerciseTabContent({Key? key}) : super(key: key);

  @override
  State<ExerciseTabContent> createState() => _ExerciseTabContentState();
}

class _ExerciseTabContentState extends State<ExerciseTabContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Days Navigation
        Consumer<ExerciseProvider>(
          builder: (context, exerciseProvider, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
                  children: ExerciseProvider.daysOfWeek.map((day) {
                    final isSelected = exerciseProvider.selectedDay == day;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          exerciseProvider.setSelectedDay(day);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? null
                                : Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            day.substring(0, 3),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),

        // Exercises List
        Expanded(
          child: Consumer<ExerciseProvider>(
            builder: (context, exerciseProvider, _) {
              final exercises = exerciseProvider.exercisesForSelectedDay;

              if (exercises.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No exercises for ${exerciseProvider.selectedDay}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              // Group exercises by the explicit 'type' field
              final warmups = exercises.where((e) => e.type == 'warm').toList();
              final workouts = exercises
                  .where((e) => e.type == 'workout')
                  .toList();
              final finishers = exercises
                  .where((e) => e.type == 'finish')
                  .toList();

              final sections = [
                MapEntry('Warm-up', warmups),
                MapEntry('Workout', workouts),
                MapEntry('Finisher', finishers),
              ];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: sections.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          section.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (section.value.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 8),
                          child: Text(
                            'No ${section.key.toLowerCase()} exercises',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ...section.value.map(
                        (exercise) => ExerciseCard(
                          exercise: exercise,
                          onDelete: () {
                            exerciseProvider.deleteExercise(exercise.id);
                          },
                          onComplete: (actualDuration) {
                            exerciseProvider.markExerciseComplete(
                              exercise.id,
                              actualDuration,
                            );
                          },
                          onReset: () {
                            exerciseProvider.resetExerciseProgress(exercise.id);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
