import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../repositories/data_repository.dart';
import '../../models/incident_model.dart';
import '../../models/service_status_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<IncidentModel> _incidents = [];
  List<ServiceStatusModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = context.read<DataRepository>();
    final incidents = await repo.getIncidents();
    final services = await repo.getServiceStatus();
    
    if (mounted) {
      setState(() {
        _incidents = incidents;
        _services = services;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatCard('Total\nIssues', _incidents.length.toString(), Colors.blue),
                    _buildStatCard('Open\nIssues', _incidents.where((i) => i.status != 'Resolved' && i.status != 'Verified').length.toString(), Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildStatCard('Resolved', _incidents.where((i) => i.status == 'Resolved').length.toString(), Colors.green),
                    _buildStatCard('Verified', _incidents.where((i) => i.status == 'Verified').length.toString(), Colors.teal),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Current Service Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._services.map((s) => Card(
                  color: s.status == 'Available' || s.status == 'ON' ? Colors.green.shade50 : Colors.red.shade50,
                  child: ListTile(
                    title: Text('${s.serviceType} - ${s.block}'),
                    subtitle: Text('Status: ${s.status}'),
                  ),
                )).toList(),
                const SizedBox(height: 24),
                const Text('All Issues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._incidents.map((e) => Card(
                  child: ListTile(
                    title: Text('${e.category} - ${e.subcategory}'),
                    subtitle: Text('Status: ${e.status}\nBlock: ${e.block}'),
                    trailing: Text(e.status, style: TextStyle(color: e.status == 'Verified' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                )).toList(),
              ],
            ),
          ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
