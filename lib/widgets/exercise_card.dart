import 'package:flutter/material.dart';
import '../widgets/inline_video_player.dart';
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
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildMediaPreview(exercise.imageUrl),
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

            // Timer or Reps Section
            if (!exercise.isCompleted)
              (exercise.durationSeconds > 0
                  ? ExerciseTimerWidget(exercise: exercise, onComplete: onComplete)
                  : _RepsTracker(
                      exercise: exercise,
                      onComplete: onComplete,
                    ))
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

// Helper to detect and render media previews (image or video placeholder)
Widget _buildMediaPreview(String url) {
  final lower = url.toLowerCase();
  final isVideo = lower.endsWith('.mp4') || lower.endsWith('.webm') || lower.endsWith('.mov') || lower.endsWith('.mkv');

  if (isVideo) {
    return InlineVideoPlayer(url: url);
  }

  // Try to show as image; keep error fallback
  if (url.startsWith('http')) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
          ),
        );
      },
    );
  }

  return Image.asset(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
        ),
      );
    },
  );
}


class _RepsTracker extends StatefulWidget {
  final Exercise exercise;
  final Function(int) onComplete;

  const _RepsTracker({required this.exercise, required this.onComplete});

  @override
  State<_RepsTracker> createState() => _RepsTrackerState();
}

class _RepsTrackerState extends State<_RepsTracker> {
  late int _count;

  @override
  void initState() {
    super.initState();
    // rep count stored in actualDurationSeconds for backwards compatibility
    _count = widget.exercise.actualDurationSeconds;
  }

  void _inc() => setState(() => _count++);
  void _dec() => setState(() { if (_count > 0) _count--; });
  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _dec,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              const SizedBox(width: 8),
              Text(
                '$_count',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _inc,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _count > 0 ? () => widget.onComplete(_count) : null,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
