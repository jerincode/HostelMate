import 'package:flutter/material.dart';
import '../../models/incident_model.dart';
import 'package:provider/provider.dart';
import '../../repositories/data_repository.dart';
import '../../services/auth_service.dart';

class IssueTrackingScreen extends StatefulWidget {
  final IncidentModel incident;

  const IssueTrackingScreen({super.key, required this.incident});

  @override
  State<IssueTrackingScreen> createState() => _IssueTrackingScreenState();
}

class _IssueTrackingScreenState extends State<IssueTrackingScreen> {
  late IncidentModel _incident;

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
  }

  void _verifyResolution(bool isResolved) async {
    final repo = context.read<DataRepository>();
    
    _incident.verificationStatus = isResolved ? 'Verified' : 'Reopened';
    _incident.status = isResolved ? 'Verified' : 'Reopened';
    _incident.verifiedAt = DateTime.now();

    await repo.updateIncident(_incident);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = context.read<AuthService>().currentUser?.role == 'student';

    return Scaffold(
      appBar: AppBar(title: Text('Incident #${_incident.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_incident.category} - ${_incident.subcategory}', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Location: ${_incident.block}, ${_incident.floor} ${_incident.room ?? ""}'),
                    const SizedBox(height: 8),
                    Text('Description: ${_incident.description}'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_incident.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(_incident.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTimelineItem('Reported', _incident.reportedAt, true),
            _buildTimelineItem('Assigned (${_incident.assignedTo ?? "Pending"})', _incident.assignedAt, _incident.assignedAt != null),
            _buildTimelineItem('Action Taken: ${_incident.actionTaken ?? "None yet"}', _incident.resolvedAt, _incident.actionTaken != null),
            _buildTimelineItem('Resolved', _incident.resolvedAt, _incident.resolvedAt != null),
            _buildTimelineItem('Verification: ${_incident.verificationStatus}', _incident.verifiedAt, _incident.verifiedAt != null, isLast: true),
            
            if (isStudent && _incident.status == 'Resolved' && _incident.verificationStatus == 'Pending') ...[
              const SizedBox(height: 32),
              const Text('Is the problem actually resolved?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => _verifyResolution(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Yes'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _verifyResolution(false),
                      icon: const Icon(Icons.close),
                      label: const Text('No'),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime? time, bool isCompleted, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.blue : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, color: isCompleted ? Colors.black : Colors.grey)),
              if (time != null)
                Text('${time.hour}:${time.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reported': return Colors.orange;
      case 'Assigned': return Colors.blue;
      case 'In Progress': return Colors.deepPurple;
      case 'Resolved': return Colors.green;
      case 'Verified': return Colors.teal;
      case 'Reopened': return Colors.red;
      default: return Colors.grey;
    }
  }
}
