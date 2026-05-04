import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

class ViolationModel extends Violation {
  const ViolationModel({
    super.id,
    required super.title,
    required super.description,
    required super.citizenName,
    super.citizenId,
    required super.amount,
    required super.departmentId,
    super.departmentName,
    super.municipalityId,
    super.municipalityName,
    required super.location,
    required super.violationDate,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) {
    return ViolationModel(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      citizenName: json['citizenName']?.toString() ?? '',
      citizenId: _toInt(json['citizenId']),
      amount: _toDouble(json['amount']),
      departmentId: _toInt(json['departmentId']) ?? 0,
      departmentName: json['departmentName']?.toString(),
      municipalityId: _toInt(json['municipalityId']),
      municipalityName: json['municipalityName']?.toString(),
      location: json['location']?.toString() ?? '',
      violationDate: json['violationDate']?.toString() ?? '',
    );
  }

  factory ViolationModel.fromEntity(Violation violation) {
    return ViolationModel(
      id: violation.id,
      title: violation.title,
      description: violation.description,
      citizenName: violation.citizenName,
      citizenId: violation.citizenId,
      amount: violation.amount,
      departmentId: violation.departmentId,
      departmentName: violation.departmentName,
      municipalityId: violation.municipalityId,
      municipalityName: violation.municipalityName,
      location: violation.location,
      violationDate: violation.violationDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citizenName': citizenName.trim(),
      'departmentId': departmentId,
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'violationDate': violationDate,
      'amount': amount,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}