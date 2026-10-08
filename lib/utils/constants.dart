class AppConstants {
  static const String appName = 'HostelMate';
  
  static const List<String> blocks = ['Block A', 'Block B', 'Block C'];
  static const List<String> floors = ['Floor 1', 'Floor 2', 'Floor 3', 'Floor 4'];
  static List<String> categories = ['Water', 'Electricity', 'Generator'];
  
  static Map<String, List<String>> subcategories = {
    'Water': ['No water', 'Low pressure', 'Dirty water', 'Other'],
    'Electricity': ['Power outage', 'Voltage issue', 'Frequent interruption', 'Other'],
    'Generator': ['Generator not started', 'Generator stopped', 'Generator issue', 'Other'],
  };
}
