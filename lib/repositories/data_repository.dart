import '../models/user_model.dart';
import '../models/incident_model.dart';
import '../models/service_status_model.dart';
import '../models/mess_menu_model.dart';
import '../models/food_feedback_model.dart';

abstract class DataRepository {
  Future<UserModel?> login(String email, String password);
  Future<List<IncidentModel>> getIncidents();
  Future<List<ServiceStatusModel>> getServiceStatus();
  Future<MessMenuModel?> getTodayMenu();
  
  Future<void> reportIncident(IncidentModel incident);
  Future<void> updateIncident(IncidentModel incident);
  Future<void> submitFoodFeedback(FoodFeedbackModel feedback);
}
