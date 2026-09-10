import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../repositories/data_repository.dart';
import '../../models/service_status_model.dart';
import '../../models/incident_model.dart';
import 'report_issue_screen.dart';
import 'issue_tracking_screen.dart';
import 'mess_menu_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  List<ServiceStatusModel> _services = [];
  List<IncidentModel> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = context.read<DataRepository>();
    final services = await repo.getServiceStatus();
    final incidents = await repo.getIncidents();
    
    if (mounted) {
      setState(() {
        _services = services;
        _incidents = incidents;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.of(context).pop(); // Back to login
            },
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Hello, ${user?.name ?? "Student"} 👋', 
                  style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                const Text('Service Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildServiceCards(),
                const SizedBox(height: 24),
                const Text('Recent Issues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._incidents.map((e) => Card(
                  child: ListTile(
                    title: Text('${e.category} - ${e.subcategory}'),
                    subtitle: Text('Status: ${e.status}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IssueTrackingScreen(incident: e)));
                    },
                  ),
                )).toList(),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportIssueScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildServiceCards() {
    return Column(
      children: _services.map((s) => Card(
        color: s.status == 'Available' || s.status == 'ON' 
            ? Colors.green.shade50 
            : Colors.red.shade50,
        child: ListTile(
          leading: Icon(
            s.serviceType == 'Water' ? Icons.water_drop :
            s.serviceType == 'Electricity' ? Icons.electrical_services : Icons.power,
            color: s.status == 'Available' || s.status == 'ON' ? Colors.green : Colors.red,
          ),
          title: Text(s.serviceType),
          subtitle: Text('Status: ${s.status}'),
        ),
      )).toList()..add(
        Card(
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.orange),
            title: const Text("Today's Mess"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MessMenuScreen()));
            },
          ),
        ),
      ),
    );
  }
}
