class Violation {
  final String title;
  final String description;
  final String citizenName;
  final double amount;
  final int departmentId;
  final String location;
  final String violationDate;

  Violation({
    required this.title,
    required this.description,
    required this.citizenName,
    required this.amount,
    required this.departmentId,
    required this.location,
    required this.violationDate,
  });
}