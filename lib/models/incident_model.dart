class IncidentModel {
  final String id;
  final String category; // Water, Electricity, Generator, Food
  final String subcategory;
  final String description;
  final String block;
  final String floor;
  final String? room;
  final String reportedBy; // User ID
  final DateTime reportedAt;
  
  String? assignedTo; // Staff ID
  DateTime? assignedAt;
  
  String? actionTaken;
  DateTime? resolvedAt;
  
  DateTime? verifiedAt;
  DateTime? expectedResolution;
  
  String status; // Reported, Assigned, In Progress, Resolved, Verified, Reopened
  String priority; // Low, Medium, High
  String verificationStatus; // Pending, Verified, Reopened
  String? imageUrl;

  IncidentModel({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.block,
    required this.floor,
    this.room,
    required this.reportedBy,
    required this.reportedAt,
    this.assignedTo,
    this.assignedAt,
    this.actionTaken,
    this.resolvedAt,
    this.verifiedAt,
    this.expectedResolution,
    this.status = 'Reported',
    this.priority = 'Medium',
    this.verificationStatus = 'Pending',
    this.imageUrl,
  });

  Duration? get resolutionTime {
    if (resolvedAt != null) {
      return resolvedAt!.difference(reportedAt);
    }
    return null;
  }
}
