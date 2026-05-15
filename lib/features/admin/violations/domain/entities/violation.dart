class Violation {
  final int? id;
  final String title;
  final String description;
  final String citizenName;
  final int? citizenId;
  final double amount;
  final int departmentId;
  final String? departmentName;
  final int? municipalityId;
  final String? municipalityName;
  final String location;
  final String violationDate;
  final String? identityNumber;
  final String? carPlate;
  final String? type;

  const Violation({
    this.id,
    required this.title,
    required this.description,
    required this.citizenName,
    this.citizenId,
    required this.amount,
    required this.departmentId,
    this.departmentName,
    this.municipalityId,
    this.municipalityName,
    required this.location,
    required this.violationDate,
    this.identityNumber,
    this.carPlate,
    this.type,
  });
}
