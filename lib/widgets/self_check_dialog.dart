import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfCheckDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const SelfCheckDialog({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<SelfCheckDialog> createState() => _SelfCheckDialogState();
}

class _SelfCheckDialogState extends State<SelfCheckDialog> {
  bool proteinTarget = false;
  bool training = false;
  bool cheating = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              "Today's Self-Check",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.egg_alt, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('Protein target'),
                ],
              ),
              value: proteinTarget,
              onChanged: (val) => setState(() => proteinTarget = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Training'),
                ],
              ),
              value: training,
              onChanged: (val) => setState(() => training = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  const Text('Cheating'),
                ],
              ),
              value: cheating,
              onChanged: (val) => setState(() => cheating = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final todayKey = _getTodayKey();
                  await prefs.setBool(todayKey, true);
                  widget.onSaved();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return 'self_check_${now.year}_${now.month}_${now.day}';
  }
}
