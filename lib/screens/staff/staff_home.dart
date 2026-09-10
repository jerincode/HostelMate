import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../repositories/data_repository.dart';
import '../../models/incident_model.dart';
import 'update_issue_screen.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({super.key});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  List<IncidentModel> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = context.read<DataRepository>();
    final incidents = await repo.getIncidents();
    
    if (mounted) {
      setState(() {
        _incidents = incidents.where((i) => i.status != 'Verified').toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
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
                Text('Hello, ${user?.name ?? "Staff"} 👋', 
                  style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                const Text('Active Issues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_incidents.isEmpty)
                  const Center(child: Text("No active issues."))
                else
                  ..._incidents.map((e) => Card(
                    child: ListTile(
                      title: Text('${e.category} - ${e.subcategory}'),
                      subtitle: Text('Block: ${e.block}, Floor: ${e.floor}\nStatus: ${e.status}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateIssueScreen(incident: e)));
                        _loadData(); // Reload after return
                      },
                    ),
                  )).toList(),
              ],
            ),
          ),
    );
  }
}
