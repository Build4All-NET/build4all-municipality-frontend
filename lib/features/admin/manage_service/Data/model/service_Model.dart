class ServiceModel {
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

  ServiceModel({
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

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      municipalityId: json['municipalityId'] ?? 0,
      departmentId: json['departmentId'] ?? 0,
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      slaDays: json['slaDays'] ?? 0,
      requiresInspection: json['requiresInspection'] ?? false,
      hasFees: json['hasFees'] ?? false,
      feeAmount: (json['feeAmount'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "municipalityId": municipalityId,
      "departmentId": departmentId,
      "nameAr": nameAr,
      "nameEn": nameEn,
      "descriptionAr": descriptionAr,
      "descriptionEn": descriptionEn,
      "slaDays": slaDays,
      "requiresInspection": requiresInspection,
      "hasFees": hasFees,
      "feeAmount": feeAmount,
      "isActive": isActive,
    };
  }
}