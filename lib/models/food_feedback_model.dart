class FoodFeedbackModel {
  final String id;
  final String studentId;
  final DateTime date;
  final String meal; // Breakfast, Lunch, Dinner
  final int taste; // 1-5
  final int quality; // 1-5
  final int quantity; // 1-5
  final int hygiene; // 1-5
  final int overall; // 1-5
  final String? comment;
  final DateTime createdAt;

  FoodFeedbackModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.meal,
    required this.taste,
    required this.quality,
    required this.quantity,
    required this.hygiene,
    required this.overall,
    this.comment,
    required this.createdAt,
  });
}
