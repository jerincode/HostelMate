class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // student, staff, admin
  final String? block;
  final String? floor;
  final String? room;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.block,
    this.floor,
    this.room,
    required this.createdAt,
  });
}
