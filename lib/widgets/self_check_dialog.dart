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
    return AlertDialog(
      title: const Text('Self-Check'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Protein target'),
            value: proteinTarget,
            onChanged: (val) => setState(() => proteinTarget = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            secondary: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Yes'),
                const SizedBox(width: 8),
                const Text('No'),
              ],
            ),
          ),
          CheckboxListTile(
            title: const Text('Training'),
            value: training,
            onChanged: (val) => setState(() => training = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            secondary: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Yes'),
                const SizedBox(width: 8),
                const Text('No'),
              ],
            ),
          ),
          CheckboxListTile(
            title: const Text('Cheating'),
            value: cheating,
            onChanged: (val) => setState(() => cheating = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            secondary: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Yes'),
                const SizedBox(width: 8),
                const Text('No'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final todayKey = _getTodayKey();
            await prefs.setBool(todayKey, true);
            widget.onSaved();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return 'self_check_${now.year}_${now.month}_${now.day}';
  }
}
