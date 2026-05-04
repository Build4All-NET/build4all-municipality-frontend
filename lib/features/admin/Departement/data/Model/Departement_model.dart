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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isFixed: json['isFixed'],
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
      "name": name,
      "description": description,
      "isFixed": isFixed,
    };
  }
}