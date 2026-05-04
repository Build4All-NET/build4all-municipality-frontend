class Service {
  final int id;
  final int municipalityId;
  final int departmentId;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final int slaDays;
  final bool requiresInspection;
  final bool hasFees;
  final double feeAmount;
  final bool isActive;

  Service({
    required this.id,
    required this.municipalityId,
    required this.departmentId,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.slaDays,
    required this.requiresInspection,
    required this.hasFees,
    required this.feeAmount,
    required this.isActive,
  });
}