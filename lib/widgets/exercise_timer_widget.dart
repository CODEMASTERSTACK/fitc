import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise.dart';

class ExerciseTimerWidget extends StatefulWidget {
  final Exercise exercise;
  final Function(int) onComplete;

  const ExerciseTimerWidget({
    Key? key,
    required this.exercise,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ExerciseTimerWidget> createState() => _ExerciseTimerWidgetState();
}

class _ExerciseTimerWidgetState extends State<ExerciseTimerWidget> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.exercise.actualDurationSeconds;
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    if (_isRunning) {
      _stopTimer();
    }
    setState(() {
      _elapsedSeconds = 0;
    });
  }

  void _completeExercise() {
    _stopTimer();
    widget.onComplete(_elapsedSeconds);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isTargetReached = _elapsedSeconds >= widget.exercise.durationSeconds;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Timer Display
          Center(
            child: Text(
              _formatTime(_elapsedSeconds),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isTargetReached ? Colors.green : Colors.blue,
                fontFamily: 'monospace',
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Target Duration Info
          Center(
            child: Text(
              'Target: ${widget.exercise.formattedDuration}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),

          if (isTargetReached)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Target reached!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Control Buttons
          Row(
            children: [
              // Start/Stop Button
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: FittedBox(child: Text(_isRunning ? 'Pause' : 'Start')),
                  style: FilledButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.orange : Colors.blue,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Reset Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const FittedBox(child: Text('Reset')),
                ),
              ),

              const SizedBox(width: 8),

              // Complete Button (visible when timer is stopped and time is > 0)
              if (!_isRunning && _elapsedSeconds > 0)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _completeExercise,
                    icon: const Icon(Icons.check),
                    label: const FittedBox(child: Text('Done')),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
