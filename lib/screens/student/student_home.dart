import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../repositories/data_repository.dart';
import '../../models/service_status_model.dart';
import '../../models/incident_model.dart';
import '../../utils/constants.dart';
import 'report_issue_screen.dart';
import 'issue_tracking_screen.dart';
import 'mess_menu_screen.dart';
import '../auth/login_screen.dart';

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
                  setState(() {});
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

  void _showProfileModal(dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  (user?.name ?? 'S')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Student',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Text(
                user?.email ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildProfileInfoRow(Icons.domain, 'Block', user?.block ?? 'Block B'),
              _buildProfileInfoRow(Icons.stairs, 'Floor', user?.floor ?? 'Floor 2'),
              _buildProfileInfoRow(Icons.meeting_room, 'Room', user?.room ?? '204'),
              _buildProfileInfoRow(Icons.phone, 'Phone', user?.phone ?? '1234567890'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
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
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.apartment, color: Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HostelMate',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Student Portal',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E40AF),
                backgroundColor: const Color(0xFFEFF6FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => _showProfileModal(user),
              icon: const Icon(Icons.person, size: 18),
              label: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              onPressed: () {
                context.read<AuthService>().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      TextButton.icon(
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF2563EB)),
                        label: const Text('Add Category', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildServiceCards(),
                  const SizedBox(height: 24),
                  const Text('Recent Issues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  ..._incidents.map((e) => Card(
                    child: ListTile(
                      title: Text(e.subcategory.isNotEmpty && e.subcategory != e.category ? '${e.category} - ${e.subcategory}' : e.category),
                      subtitle: Text('Status: ${e.status}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => IssueTrackingScreen(incident: e))).then((_) => _loadData());
                      },
                    ),
                  )),
                ],
              ),
            ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportIssueScreen())).then((_) => _loadData());
          },
          icon: const Icon(Icons.add),
          label: const Text('Report Issue', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildServiceCards() {
    return Column(
      children: _services.map((s) => Card(
        color: s.status == 'Available' || s.status == 'ON' 
            ? const Color(0xFFECFDF5) // Light Emerald
            : const Color(0xFFFEF2F2), // Light Red
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: s.status == 'Available' || s.status == 'ON' ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              s.serviceType == 'Water' ? Icons.water_drop :
              s.serviceType == 'Electricity' ? Icons.electrical_services : Icons.power,
              color: s.status == 'Available' || s.status == 'ON' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
          title: Text(s.serviceType, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Status: ${s.status}'),
        ),
      )).toList()..add(
        Card(
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, color: Color(0xFFF59E0B)),
            ),
            title: const Text("Today's Mess", style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MessMenuScreen()));
            },
          ),
        ),
      ),
    );
  }
}
