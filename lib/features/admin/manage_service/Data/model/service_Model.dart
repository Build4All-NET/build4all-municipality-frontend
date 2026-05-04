import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  ServiceModel({
     required super.id,
    required super.municipalityId,
    required super.departmentId,
    required super.nameAr,
    required super.nameEn,
    required super.descriptionAr,
    required super.descriptionEn,
    required super.slaDays,
    required super.requiresInspection,
    required super.hasFees,
    required super.feeAmount,
    required super.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      municipalityId: json['municipalityId'],
      departmentId: json['departmentId'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      descriptionAr: json['descriptionAr'],
      descriptionEn: json['descriptionEn'],
      slaDays: json['slaDays'],
      requiresInspection: json['requiresInspection'],
      hasFees: json['hasFees'],
      feeAmount: (json['feeAmount'] as num).toDouble(),
      isActive: json['isActive'],
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