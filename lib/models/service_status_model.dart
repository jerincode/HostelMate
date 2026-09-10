class ServiceStatusModel {
  final String serviceType; // Water, Electricity, Generator
  final String block;
  final String floor;
  String status; // e.g. Available, Outage, ON, OFF
  DateTime updatedAt;
  String updatedBy; // Admin or System ID
  DateTime? expectedRestoration;

  ServiceStatusModel({
    required this.serviceType,
    required this.block,
    required this.floor,
    required this.status,
    required this.updatedAt,
    required this.updatedBy,
    this.expectedRestoration,
  });
}
