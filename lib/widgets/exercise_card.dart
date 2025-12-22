import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'exercise_timer_widget.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onDelete;
  final Function(int) onComplete;
  final VoidCallback onReset;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.onDelete,
    required this.onComplete,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: const Text('Delete'), onTap: onDelete),
                  ],
                  child: Icon(Icons.more_vert, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Image/Video Preview
            if (exercise.imageUrl.isNotEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: exercise.imageUrl.startsWith('http')
                      ? Image.network(
                          exercise.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          exercise.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                ),
              ),

            if (exercise.imageUrl.isNotEmpty) const SizedBox(height: 12),

            // Duration Info
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'Target: ${exercise.formattedDuration}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Timer Section
            if (!exercise.isCompleted)
              ExerciseTimerWidget(exercise: exercise, onComplete: onComplete)
            else
              // Completed state
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration: ${exercise.formattedActualDuration}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        TextButton(
                          onPressed: onReset,
                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
