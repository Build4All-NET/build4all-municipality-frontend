import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    super.municipalityId,
    super.departmentId,
    required super.nameAr,
    required super.nameEn,
    required super.descriptionAr,
    required super.descriptionEn,
    super.slaDays,
    super.requiresInspection,
    super.hasFees,
    super.feeAmount,
    super.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: _toInt(json['id']) ?? 0,
      municipalityId: _toInt(json['municipalityId']),
      departmentId: _toInt(json['departmentId']),
      nameAr: (json['nameAr'] ?? json['name_ar'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? json['name_en'] ?? json['name'] ?? '').toString(),
      descriptionAr: (json['descriptionAr'] ?? json['description_ar'] ?? '').toString(),
      descriptionEn: (json['descriptionEn'] ?? json['description_en'] ?? json['description'] ?? '').toString(),
      slaDays: _toInt(json['slaDays'] ?? json['sla_days']),
      requiresInspection: _toBool(json['requiresInspection'] ?? json['requires_inspection']),
      hasFees: _toBool(json['hasFees'] ?? json['has_fees']),
      feeAmount: _toDouble(json['feeAmount'] ?? json['fee_amount']),
      isActive: _toBool(json['isActive'] ?? json['is_active'] ?? true),
    );
  }

  factory ServiceModel.fromEntity(ServiceEntity e) {
    return ServiceModel(
      id: e.id,
      municipalityId: e.municipalityId,
      departmentId: e.departmentId,
      nameAr: e.nameAr,
      nameEn: e.nameEn,
      descriptionAr: e.descriptionAr,
      descriptionEn: e.descriptionEn,
      slaDays: e.slaDays,
      requiresInspection: e.requiresInspection,
      hasFees: e.hasFees,
      feeAmount: e.feeAmount,
      isActive: e.isActive,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    return double.tryParse(v.toString());
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    return v.toString().toLowerCase() == 'true' || v.toString() == '1';
  }
}
