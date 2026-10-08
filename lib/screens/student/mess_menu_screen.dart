import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/data_repository.dart';
import '../../models/mess_menu_model.dart';
import 'food_feedback_screen.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({super.key});

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  MessMenuModel? _menu;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final repo = context.read<DataRepository>();
    final menu = await repo.getTodayMenu();
    if (mounted) {
      setState(() {
        _menu = menu;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Mess Menu")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menu == null
              ? const Center(child: Text("No menu available today."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMealCard('Breakfast', _menu!.breakfast),
                      const SizedBox(height: 16),
                      _buildMealCard('Lunch', _menu!.lunch),
                      const SizedBox(height: 16),
                      _buildMealCard('Dinner', _menu!.dinner),
                      const Spacer(),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodFeedbackScreen()));
                          },
                          child: const Text('Submit Food Feedback'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMealCard(String mealName, String menu) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mealName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 8),
            Text(menu, style: const TextStyle(fontSize: 16, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}
