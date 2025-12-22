import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';
import '../models/exercise.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/export_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export data'),
            subtitle: const Text(
              'Download your food, water, exercise, and self-check data as PDF.',
            ),
            onTap: () async {
              final period = await showModalBottomSheet<String>(
                context: context,
                builder: (ctx) => _ExportOptionsSheet(),
              );
              if (period != null) {
                await _exportData(context, period);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blue[700]),
            title: const Text('App Info'),
            subtitle: const Text('Fitc v0.1.0'),
          ),
          ListTile(
            leading: Icon(Icons.feedback_outlined, color: Colors.green[700]),
            title: const Text('Send Feedback'),
            subtitle: const Text('Let us know your thoughts!'),
            onTap: () {
              // TODO: Implement feedback feature
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.color_lens_outlined, color: Colors.purple[700]),
            title: const Text('Theme'),
            subtitle: const Text('Light / Dark (coming soon)'),
            onTap: () {
              // TODO: Implement theme toggle
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, String period) async {
    final now = DateTime.now();
    int days = 1;
    if (period == '1w') days = 7;
    if (period == '2w') days = 14;
    final List<DateTime> exportDays = List.generate(
      days,
      (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: i)),
    ).reversed.toList();

    // Fetch data for each day (replace with your actual storage logic)
    final storage = StorageService();
    await storage.init();
    final food = <DateTime, List<FoodEntry>>{};
    final exercise = <DateTime, List<Exercise>>{};
    final water = <DateTime, List<WaterEntry>>{};
    final selfCheck = <DateTime, Map<String, bool>>{};
    for (final day in exportDays) {
      food[day] = (await storage.getFoodEntriesForDate(day)).cast<FoodEntry>();
      water[day] = (await storage.getWaterEntriesForDate(
        day,
      )).cast<WaterEntry>();
      // TODO: Add exercise and self-check fetch logic
    }
    final file = await ExportService.exportDataToPdf(
      days: exportDays,
      food: food,
      exercise: exercise,
      water: water,
      selfCheck: selfCheck,
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Exported to: ${file.path}')));
  }
}

class _ExportOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Export 1 day'),
            onTap: () => Navigator.of(context).pop('1d'),
          ),
          ListTile(
            title: const Text('Export 1 week'),
            onTap: () => Navigator.of(context).pop('1w'),
          ),
          ListTile(
            title: const Text('Export 2 weeks'),
            onTap: () => Navigator.of(context).pop('2w'),
          ),
        ],
      ),
    );
  }
}
