class ServiceEntity {
  final int id;
  final int? municipalityId;
  final int? departmentId;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final int? slaDays;
  final bool requiresInspection;
  final bool hasFees;
  final double? feeAmount;
  final bool isActive;

  const ServiceEntity({
    required this.id,
    this.municipalityId,
    this.departmentId,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    this.slaDays,
    this.requiresInspection = false,
    this.hasFees = false,
    this.feeAmount,
    this.isActive = true,
  });

  String localizedName(String languageCode) {
    if (languageCode == 'ar') return nameAr.isNotEmpty ? nameAr : nameEn;
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  String localizedDescription(String languageCode) {
    if (languageCode == 'ar') return descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;
    return descriptionEn.isNotEmpty ? descriptionEn : descriptionAr;
  }
}
