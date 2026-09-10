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
  String? _selectedSubcategory;
  String? _selectedBlock;
  String? _selectedFloor;
  
  final _roomController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isSubmitting = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      final user = context.read<AuthService>().currentUser!;
      final repo = context.read<DataRepository>();
      
      final incident = IncidentModel(
        id: 'HM${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        category: _selectedCategory!,
        subcategory: _selectedSubcategory!,
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Service Category', border: OutlineInputBorder()),
                value: _selectedCategory,
                items: AppConstants.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                    _selectedSubcategory = null;
                  });
                },
                validator: (val) => val == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedCategory != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Problem Type', border: OutlineInputBorder()),
                  value: _selectedSubcategory,
                  items: AppConstants.subcategories[_selectedCategory]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedSubcategory = val),
                  validator: (val) => val == null ? 'Please select a problem type' : null,
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Block', border: OutlineInputBorder()),
                      value: _selectedBlock,
                      items: AppConstants.blocks.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _selectedBlock = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder()),
                      value: _selectedFloor,
                      items: AppConstants.floors.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _selectedFloor = val),
                      validator: (val) => val == null ? 'Required' : null,
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
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
