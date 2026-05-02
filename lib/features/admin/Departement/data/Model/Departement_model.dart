import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';

class DepartmentModel extends Department {
  DepartmentModel({
    required super.id,
    required super.name,
    required super.description,
    required super.isFixed,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isFixed: json['isFixed'],
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