import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../repositories/data_repository.dart';
import '../../services/auth_service.dart';

class UpdateIssueScreen extends StatefulWidget {
  final IncidentModel incident;

  const UpdateIssueScreen({super.key, required this.incident});

  @override
  State<UpdateIssueScreen> createState() => _UpdateIssueScreenState();
}

class _UpdateIssueScreenState extends State<UpdateIssueScreen> {
  late IncidentModel _incident;
  final _actionController = TextEditingController();
  String _selectedStatus = 'In Progress';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
    _actionController.text = _incident.actionTaken ?? '';
    _selectedStatus = _incident.status == 'Reported' ? 'Assigned' : _incident.status;
  }

  void _update() async {
    setState(() => _isUpdating = true);
    
    final repo = context.read<DataRepository>();
    final user = context.read<AuthService>().currentUser!;
    
    _incident.status = _selectedStatus;
    _incident.actionTaken = _actionController.text;
    
    if (_selectedStatus == 'Assigned' && _incident.assignedTo == null) {
      _incident.assignedTo = user.name;
      _incident.assignedAt = DateTime.now();
    }
    
    if (_selectedStatus == 'Resolved') {
      _incident.resolvedAt = DateTime.now();
    }
    
    await repo.updateIncident(_incident);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue updated successfully.')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Issue #${_incident.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
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
                    Text('Category: ${_incident.category} - ${_incident.subcategory}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Location: ${_incident.block}, ${_incident.floor} ${_incident.room ?? ""}'),
                    const SizedBox(height: 8),
                    Text('Description: ${_incident.description}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
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
                    value: ['Reported', 'Assigned', 'In Progress', 'Resolved', 'Verified', 'Reopened'].contains(_selectedStatus) ? _selectedStatus : null,
                    items: ['Assigned', 'In Progress', 'Resolved'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _actionController,
              decoration: const InputDecoration(
                labelText: 'Action Taken',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _update,
                child: _isUpdating ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Issue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
