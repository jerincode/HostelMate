import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../repositories/data_repository.dart';
import '../../models/food_feedback_model.dart';

class FoodFeedbackScreen extends StatefulWidget {
  const FoodFeedbackScreen({super.key});

  @override
  State<FoodFeedbackScreen> createState() => _FoodFeedbackScreenState();
}

class _FoodFeedbackScreenState extends State<FoodFeedbackScreen> {
  String _selectedMeal = 'Lunch';
  int _taste = 3;
  int _quality = 3;
  int _quantity = 3;
  int _hygiene = 3;
  int _overall = 3;
  final _commentController = TextEditingController();

  void _submit() async {
    final repo = context.read<DataRepository>();
    final user = context.read<AuthService>().currentUser!;

    final feedback = FoodFeedbackModel(
      id: 'FB${DateTime.now().millisecondsSinceEpoch}',
      studentId: user.id,
      date: DateTime.now(),
      meal: _selectedMeal,
      taste: _taste,
      quality: _quality,
      quantity: _quantity,
      hygiene: _hygiene,
      overall: _overall,
      comment: _commentController.text,
      createdAt: DateTime.now(),
    );

    await repo.submitFoodFeedback(feedback);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted. Thank you!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Meal', border: OutlineInputBorder()),
              value: _selectedMeal,
              items: ['Breakfast', 'Lunch', 'Dinner'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedMeal = val!),
            ),
            const SizedBox(height: 24),
            _buildRatingRow('Taste', _taste, (val) => setState(() => _taste = val)),
            _buildRatingRow('Quality', _quality, (val) => setState(() => _quality = val)),
            _buildRatingRow('Quantity', _quantity, (val) => setState(() => _quantity = val)),
            _buildRatingRow('Hygiene', _hygiene, (val) => setState(() => _hygiene = val)),
            _buildRatingRow('Overall Satisfaction', _overall, (val) => setState(() => _overall = val)),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Additional Comments (Optional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < value ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => onChanged(index + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }),
          )
        ],
      ),
    );
  }
}
