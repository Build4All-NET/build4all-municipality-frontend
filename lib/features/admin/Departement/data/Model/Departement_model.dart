import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';

class DepartmentModel {
  final int id;
  final String name;
  final String description;
  final bool isFixed;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isFixed,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isFixed: _toBool(json['isFixed']),
    );
  }

  factory DepartmentModel.fromEntity(Department entity) {
    return DepartmentModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isFixed: entity.isFixed,
    );
  }

  Department toEntity() {
    return Department(
      id: id,
      name: name,
      description: description,
      isFixed: isFixed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isFixed': isFixed,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final text = value?.toString().toLowerCase().trim();

    return text == 'true' || text == '1' || text == 'yes';
  }
}