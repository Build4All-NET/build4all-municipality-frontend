import '../../domain/entities/citizen_service_entity.dart';

class CitizenServiceModel extends CitizenServiceEntity {
  const CitizenServiceModel({
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

  factory CitizenServiceModel.fromJson(Map<String, dynamic> json) {
    return CitizenServiceModel(
      id: _toInt(json['id']),
      municipalityId: _toNullableInt(
        json['municipalityId'] ?? json['municipality']?['id'],
      ),
      departmentId: _toNullableInt(
        json['departmentId'] ?? json['department']?['id'],
      ),
      nameAr: _toStringValue(json['nameAr'] ?? json['name']),
      nameEn: _toStringValue(json['nameEn'] ?? json['name']),
      descriptionAr: _toStringValue(
        json['descriptionAr'] ?? json['description'],
      ),
      descriptionEn: _toStringValue(
        json['descriptionEn'] ?? json['description'],
      ),
      slaDays: _toInt(json['slaDays']),
      requiresInspection: _toBool(json['requiresInspection']),
      hasFees: _toBool(json['hasFees']),
      feeAmount: _toDouble(json['feeAmount']),
      isActive: _toBool(json['isActive'], defaultValue: true),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();

  return int.tryParse(value.toString());
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();

  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

bool _toBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;

  final text = value.toString().trim().toLowerCase();

  return text == 'true' || text == '1' || text == 'yes';
}

String _toStringValue(dynamic value) {
  return value?.toString() ?? '';
}