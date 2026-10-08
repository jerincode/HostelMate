import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../repositories/data_repository.dart';
import '../../models/incident_model.dart';
import 'update_issue_screen.dart';
import '../auth/login_screen.dart';

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
        _incidents = incidents;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.read<AuthService>().logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Staff Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthService>().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text('${e.category} - ${e.subcategory}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Block: ${e.block}, Floor: ${e.floor}\nStatus: ${e.status}'),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit, color: Color(0xFF4F46E5), size: 20),
                        ),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateIssueScreen(incident: e)));
                          _loadData();
                        },
                      ),
                    )),
                ],
              ),
            ),
      ),
    );
  }
}
