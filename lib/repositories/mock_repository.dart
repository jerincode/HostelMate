import '../models/user_model.dart';
import '../models/incident_model.dart';
import '../models/service_status_model.dart';
import '../models/mess_menu_model.dart';
import '../models/food_feedback_model.dart';
import 'data_repository.dart';

class MockRepository implements DataRepository {
  UserModel? currentUser;

  final List<UserModel> _users = [
    UserModel(
      id: 'student1',
      name: 'John Doe',
      email: 'student@example.com',
      phone: '1234567890',
      role: 'student',
      block: 'Block B',
      floor: 'Floor 2',
      room: '204',
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: 'staff1',
      name: 'Maintenance Staff',
      email: 'staff@example.com',
      phone: '0987654321',
      role: 'staff',
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: 'admin1',
      name: 'Admin User',
      email: 'admin@example.com',
      phone: '1111111111',
      role: 'admin',
      createdAt: DateTime.now(),
    ),
  ];

  final List<IncidentModel> _incidents = [
    IncidentModel(
      id: 'HM1001',
      category: 'Water',
      subcategory: 'Water Outage',
      description: 'No water in the washroom',
      block: 'Block B',
      floor: 'Floor 2',
      room: '204',
      reportedBy: 'student1',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
      assignedTo: 'Maintenance Team',
      assignedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      actionTaken: 'Checked the pump',
      resolvedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      status: 'Resolved',
      verificationStatus: 'Pending',
    ),
    IncidentModel(
      id: 'HM1002',
      category: 'Electricity',
      subcategory: 'Power Outage',
      description: 'Power cut in Block A',
      block: 'Block A',
      floor: 'Floor 1',
      reportedBy: 'student2',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      status: 'Reported',
      verificationStatus: 'Pending',
    )
  ];

  final List<ServiceStatusModel> _serviceStatus = [
    ServiceStatusModel(
      serviceType: 'Water',
      block: 'Block B',
      floor: 'All',
      status: 'Outage',
      updatedAt: DateTime.now(),
      updatedBy: 'system',
      expectedRestoration: DateTime.now().add(const Duration(hours: 2)),
    ),
    ServiceStatusModel(
      serviceType: 'Electricity',
      block: 'Block A',
      floor: 'All',
      status: 'Outage',
      updatedAt: DateTime.now(),
      updatedBy: 'system',
    ),
    ServiceStatusModel(
      serviceType: 'Generator',
      block: 'All',
      floor: 'All',
      status: 'ON',
      updatedAt: DateTime.now(),
      updatedBy: 'system',
    ),
  ];

  final MessMenuModel _todayMenu = MessMenuModel(
    date: DateTime.now(),
    breakfast: 'Idli + Sambar + Chutney',
    lunch: 'Rice + Sambar + Vegetable Curry',
    dinner: 'Chapati + Kurma + Rice',
    updatedBy: 'admin1',
    updatedAt: DateTime.now(),
  );

  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final user = _users.firstWhere((u) => u.email == email);
      currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<IncidentModel>> getIncidents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_incidents.reversed);
  }

  @override
  Future<List<ServiceStatusModel>> getServiceStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _serviceStatus;
  }

  @override
  Future<MessMenuModel?> getTodayMenu() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _todayMenu;
  }

  @override
  Future<void> reportIncident(IncidentModel incident) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _incidents.add(incident);
  }

  @override
  Future<void> updateIncident(IncidentModel incident) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _incidents.indexWhere((i) => i.id == incident.id);
    if (index != -1) {
      _incidents[index] = incident;
    }
  }

  @override
  Future<void> submitFoodFeedback(FoodFeedbackModel feedback) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app we'd save this
  }
}
