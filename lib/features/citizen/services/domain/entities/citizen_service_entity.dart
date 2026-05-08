class CitizenServiceEntity {
  final int id;
  final int? municipalityId;
  final int? departmentId;

  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;

  final int slaDays;
  final bool requiresInspection;
  final bool hasFees;
  final double feeAmount;
  final bool isActive;

  const CitizenServiceEntity({
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

  String localizedName({required bool isArabic}) {
    if (isArabic && nameAr.trim().isNotEmpty) return nameAr;
    if (!isArabic && nameEn.trim().isNotEmpty) return nameEn;

    return nameAr.trim().isNotEmpty ? nameAr : nameEn;
  }

  String localizedDescription({required bool isArabic}) {
    if (isArabic && descriptionAr.trim().isNotEmpty) return descriptionAr;
    if (!isArabic && descriptionEn.trim().isNotEmpty) return descriptionEn;

    return descriptionAr.trim().isNotEmpty ? descriptionAr : descriptionEn;
  }
}