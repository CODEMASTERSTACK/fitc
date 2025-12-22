import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../widgets/water_entry_card.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class WaterScreen extends StatelessWidget {
  const WaterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liquid Intake'), elevation: 0),
      body: const LiquidTabContent(),
    );
  }
}

class LiquidTabContent extends StatefulWidget {
  const LiquidTabContent({Key? key}) : super(key: key);

  @override
  State<LiquidTabContent> createState() => _LiquidTabContentState();
}

class _LiquidTabContentState extends State<LiquidTabContent> {
  String selectedDrink = 'water';
  final List<String> drinks = [
    'water',
    'tea',
    'coffee',
    'juice',
    'soda',
    'other',
  ];

  // Unit conversions to ml: water=ml, tea/coffee=cups
  final Map<String, double> drinkToMl = {
    'water': 1.0, // 1ml = 1ml
    'tea': 240.0, // 1 cup = 240ml
    'coffee': 240.0, // 1 cup = 240ml
    'juice': 240.0, // 1 cup = 240ml
    'soda': 355.0, // 1 can = 355ml
    'other': 240.0, // 1 cup = 240ml
  };

  final Map<String, String> drinkUnits = {
    'water': 'ml',
    'tea': 'cups',
    'coffee': 'cups',
    'juice': 'cups',
    'soda': 'cans',
    'other': 'cups',
  };

  Color _getDrinkColor(String drink) {
    switch (drink) {
      case 'water':
        return Colors.blue;
      case 'tea':
        return Colors.amber;
      case 'coffee':
        return Colors.brown;
      case 'juice':
        return Colors.orange;
      case 'soda':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  void _addLiquid(BuildContext context, double amount) {
    final mlAmount = amount * (drinkToMl[selectedDrink] ?? 240.0);
    context.read<WaterProvider>().addWaterEntry(mlAmount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${amount.toStringAsFixed(1)} ${drinkUnits[selectedDrink]} of ${selectedDrink.capitalize()}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Drink Type Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Drink',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: drinks
                        .map(
                          (drink) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: selectedDrink == drink,
                              onSelected: (selected) {
                                setState(() {
                                  selectedDrink = drink;
                                });
                              },
                              label: Text(drink.capitalize()),
                              backgroundColor: Colors.grey[100],
                              selectedColor: _getDrinkColor(
                                drink,
                              ).withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: selectedDrink == drink
                                    ? _getDrinkColor(drink)
                                    : Colors.grey[700],
                                fontWeight: selectedDrink == drink
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              avatar: selectedDrink == drink
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: _getDrinkColor(drink),
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Daily Goal Progress
          Consumer<WaterProvider>(
            builder: (context, waterProvider, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getDrinkColor(selectedDrink).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getDrinkColor(selectedDrink).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.local_drink,
                      size: 40,
                      color: _getDrinkColor(selectedDrink),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${waterProvider.totalWaterToday.toStringAsFixed(0)} ml',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of ${waterProvider.dailyGoal.toStringAsFixed(0)} ml daily goal',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value:
                            (waterProvider.totalWaterToday /
                                    waterProvider.dailyGoal)
                                .clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getDrinkColor(selectedDrink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (waterProvider.totalWaterToday >=
                        waterProvider.dailyGoal)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✓ Daily goal achieved!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Quick Add Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Add',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: _buildQuickAddButtons(),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _CustomLiquidInput(
                  onAdd: _addLiquid,
                  unit: drinkUnits[selectedDrink] ?? 'ml',
                  drink: selectedDrink,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Today's Entries
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Intake',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
                      Icon(
                        Icons.local_drink_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No liquid entries yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
    );
  }

  List<Widget> _buildQuickAddButtons() {
    final unit = drinkUnits[selectedDrink] ?? 'ml';

    if (selectedDrink == 'water') {
      return [
        _QuickAddButton(
          label: '250 ml',
          amount: 250,
          onPressed: () => _addLiquid(context, 250),
          color: _getDrinkColor(selectedDrink),
        ),
        _QuickAddButton(
          label: '500 ml',
          amount: 500,
          onPressed: () => _addLiquid(context, 500),
          color: _getDrinkColor(selectedDrink),
        ),
        _QuickAddButton(
          label: '1 L',
          amount: 1000,
          onPressed: () => _addLiquid(context, 1000),
          color: _getDrinkColor(selectedDrink),
        ),
      ];
    } else {
      return [
        _QuickAddButton(
          label: '0.5 $unit',
          amount: 0.5,
          onPressed: () => _addLiquid(context, 0.5),
          color: _getDrinkColor(selectedDrink),
        ),
        _QuickAddButton(
          label: '1 $unit',
          amount: 1,
          onPressed: () => _addLiquid(context, 1),
          color: _getDrinkColor(selectedDrink),
        ),
        _QuickAddButton(
          label: '2 $unit',
          amount: 2,
          onPressed: () => _addLiquid(context, 2),
          color: _getDrinkColor(selectedDrink),
        ),
      ];
    }
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback onPressed;
  final Color color;

  const _QuickAddButton({
    Key? key,
    required this.label,
    required this.amount,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }
}

class _CustomLiquidInput extends StatefulWidget {
  final Function(BuildContext, double) onAdd;
  final String unit;
  final String drink;

  const _CustomLiquidInput({
    Key? key,
    required this.onAdd,
    required this.unit,
    required this.drink,
  }) : super(key: key);

  @override
  State<_CustomLiquidInput> createState() => _CustomLiquidInputState();
}

class _CustomLiquidInputState extends State<_CustomLiquidInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              labelText: widget.unit,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_controller.text);
            if (amount != null && amount > 0) {
              widget.onAdd(context, amount);
              _controller.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
