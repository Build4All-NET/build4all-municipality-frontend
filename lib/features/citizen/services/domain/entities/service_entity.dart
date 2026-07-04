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
    if (languageCode == 'fr') {
      return switch (nameEn) {
        'Building Permit' => "Permis de construire",
        'Larger Building Permit' => "Permis de construire (grande superficie)",
        'Housing Permit' => "Permis d'habitation",
        'External Works' => 'Travaux extérieurs',
        'Illegal Construction' => 'Régularisation de construction illégale',
        'Valuation Certificate' => "Certificat d'évaluation",
        'Clearance Certificate' => 'Certificat de non-redevance',
        'Tent Permit' => 'Permis de tente',
        'Property Access' => "Autorisation d'accès à la propriété",
        'Residence Certificate' => 'Certificat de résidence',
        'Contents Certificate' => 'Attestation de contenu',
        'Work Certificate' => 'Attestation de travaux',
        'Lease Registration' => 'Enregistrement de bail',
        _ => nameEn,
      };
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  String localizedDescription(String languageCode) {
    if (languageCode == 'ar') return descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;
    return descriptionEn.isNotEmpty ? descriptionEn : descriptionAr;
  }
}
