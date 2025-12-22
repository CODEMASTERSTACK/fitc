import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food Entry'), elevation: 0),
      body: const FoodTabContent(),
    );
  }
}

class FoodTabContent extends StatefulWidget {
  const FoodTabContent({Key? key}) : super(key: key);

  @override
  State<FoodTabContent> createState() => _FoodTabContentState();
}

class _FoodTabContentState extends State<FoodTabContent> {
  final nameController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatsController = TextEditingController();
  final quantityController = TextEditingController();

  String selectedMealType = 'breakfast';
  String selectedCategory = 'none';
  DateTime selectedTime = DateTime.now();

  final List<String> mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
  final List<String> categories = [
    'protein',
    'carbs',
    'fats',
    'liquid',
    'vegetables',
    'fruits',
    'none',
  ];

  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime),
    );
    if (picked != null) {
      setState(() {
        selectedTime = DateTime(
          selectedTime.year,
          selectedTime.month,
          selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _addFood() {
    if (nameController.text.isEmpty || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    context.read<FoodProvider>().addFoodEntry(
      name: nameController.text,
      calories: double.tryParse(caloriesController.text) ?? 0,
      protein: double.tryParse(proteinController.text) ?? 0,
      carbs: double.tryParse(carbsController.text) ?? 0,
      fats: double.tryParse(fatsController.text) ?? 0,
      quantity: double.parse(quantityController.text),
      mealType: selectedMealType,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Food entry added!')));

    // clear fields so user can add another quickly
    nameController.clear();
    caloriesController.clear();
    proteinController.clear();
    carbsController.clear();
    fatsController.clear();
    quantityController.clear();
    setState(() {
      selectedTime = DateTime.now();
      selectedCategory = 'none';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Type Selection
          _buildSectionLabel('Meal Type'),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: mealTypes
                .map(
                  (type) => ButtonSegment(
                    value: type,
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 80),
                      alignment: Alignment.center,
                      child: Text(
                        type.capitalize(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                )
                .toList(),
            selected: {selectedMealType},
            onSelectionChanged: (value) {
              setState(() {
                selectedMealType = value.first;
              });
            },
          ),

          const SizedBox(height: 28),

          // Time Picker
          _buildSectionLabel('Time'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Food Name
          _buildSectionLabel('Food Name *'),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: _buildInputDecoration('e.g., Dal, Roti, Curry. etc'),
          ),

          const SizedBox(height: 16),

          // Quantity
          _buildSectionLabel('Quantity (grams) *'),
          const SizedBox(height: 8),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration('e.g., 100'),
          ),

          const SizedBox(height: 28),

          // Calories (Optional)
          _buildSectionLabel('Calories (kcal)'),
          const SizedBox(height: 8),
          TextField(
            controller: caloriesController,
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration('Optional - e.g., 165'),
          ),

          const SizedBox(height: 28),

          // Category Selection
          _buildSectionLabel('Category'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => FilterChip(
                    selected: selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    label: Text(category.capitalize()),
                    backgroundColor: Colors.grey[100],
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedCategory == category
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 28),

          // Macro Nutrients Section
          _buildSectionLabel('Macro Nutrients'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroInput('Protein', 'g', proteinController),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildMacroInput('Carbs', 'g', carbsController)),
              const SizedBox(width: 12),
              Expanded(child: _buildMacroInput('Fats', 'g', fatsController)),
            ],
          ),

          const SizedBox(height: 36),

          // Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addFood,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(
                'Add Food Entry',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildMacroInput(
    String label,
    String unit,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            suffixText: unit,
            suffixStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      ],
    );
  }
}

extension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
