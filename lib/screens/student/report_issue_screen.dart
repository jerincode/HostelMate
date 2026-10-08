import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../repositories/data_repository.dart';
import '../../models/incident_model.dart';
import '../../utils/constants.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedCategory;
  String? _selectedBlock;
  String? _selectedFloor;
  
  final _roomController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isSubmitting = false;

  void _showAddCategoryDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Service Category'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'e.g. Wi-Fi / Internet, Laundry, Plumbing',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final categoryName = textController.text.trim();
                if (categoryName.isNotEmpty) {
                  if (!AppConstants.categories.contains(categoryName)) {
                    AppConstants.categories.add(categoryName);
                  }
                  setState(() {
                    _selectedCategory = categoryName;
                  });
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service category')),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      
      final user = context.read<AuthService>().currentUser!;
      final repo = context.read<DataRepository>();
      
      final incident = IncidentModel(
        id: 'HM${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        category: _selectedCategory!,
        subcategory: _selectedCategory!,
        description: _descriptionController.text,
        block: _selectedBlock ?? user.block ?? 'Unknown',
        floor: _selectedFloor ?? user.floor ?? 'Unknown',
        room: _roomController.text.isNotEmpty ? _roomController.text : user.room,
        reportedBy: user.id,
        reportedAt: DateTime.now(),
      );
      
      await repo.reportIncident(incident);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your issue has been reported successfully.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Service Category'),
                            value: _selectedCategory,
                            items: AppConstants.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Service Category'),
                ),
              ),
              if (_selectedCategory == null)
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 8),
                  child: Text('Please select a category', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Block'),
                            value: _selectedBlock,
                            items: AppConstants.blocks.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setState(() => _selectedBlock = val),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Floor'),
                            value: _selectedFloor,
                            items: AppConstants.floors.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setState(() => _selectedFloor = val),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Room Number (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
