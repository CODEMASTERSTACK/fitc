import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../widgets/water_entry_card.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({Key? key}) : super(key: key);

  void _addWater(BuildContext context, double volume) {
    context.read<WaterProvider>().addWaterEntry(volume);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${volume.toStringAsFixed(0)}ml water!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Intake'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Daily Goal Progress
            Consumer<WaterProvider>(
              builder: (context, waterProvider, _) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${waterProvider.totalWaterToday.toStringAsFixed(0)} ml',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'of ${waterProvider.dailyGoal.toStringAsFixed(0)} ml',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(height: 16),
                      if (waterProvider.totalWaterToday >=
                          waterProvider.dailyGoal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '✓ Daily goal achieved!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Quick Add Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Add',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      _QuickAddButton(
                        label: '250 ml',
                        onPressed: () => _addWater(context, 250),
                      ),
                      _QuickAddButton(
                        label: '500 ml',
                        onPressed: () => _addWater(context, 500),
                      ),
                      _QuickAddButton(
                        label: '1000 ml',
                        onPressed: () => _addWater(context, 1000),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Custom Add
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Amount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _CustomWaterInput(onAdd: _addWater),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Today's Water Entries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Water Intake',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Consumer<WaterProvider>(
              builder: (context, waterProvider, _) {
                if (waterProvider.todaysWater.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.water, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No water entries yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: waterProvider.todaysWater.length,
                  itemBuilder: (context, index) {
                    final water = waterProvider.todaysWater[index];
                    return WaterEntryCard(
                      volume: water.volume,
                      formattedTime: water.formattedTime,
                      onDelete: () {
                        waterProvider.deleteWaterEntry(water.id);
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickAddButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }
}

class _CustomWaterInput extends StatefulWidget {
  final Function(BuildContext, double) onAdd;

  const _CustomWaterInput({required this.onAdd});

  @override
  State<_CustomWaterInput> createState() => _CustomWaterInputState();
}

class _CustomWaterInputState extends State<_CustomWaterInput> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount in ml',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter an amount')),
              );
              return;
            }

            final volume = double.parse(controller.text);
            widget.onAdd(context, volume);
            controller.clear();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
