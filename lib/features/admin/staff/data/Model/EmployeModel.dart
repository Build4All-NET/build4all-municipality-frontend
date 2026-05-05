import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';

class EmployeeModel extends Employee {
  EmployeeModel({
    int? id,
    required String name,
    required String email,
    required String phone,
    required int roleId,
    required int depId,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          roleId: roleId,
          depId: depId,
        );

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: _toNullableInt(json['id']),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      roleId: _toInt(
        json['roleId'] ??
            json['role_id'] ??
            json['role']?['id'],
      ),
      depId: _toInt(
        json['depId'] ??
            json['departmentId'] ??
            json['department_id'] ??
            json['department']?['id'],
      ),
    );
  }

  factory EmployeeModel.fromEntity(Employee employee) {
    return EmployeeModel(
      id: employee.id,
      name: employee.name,
      email: employee.email,
      phone: employee.phone,
      roleId: employee.roleId,
      depId: employee.depId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'roleId': roleId,
      'depId': depId,
    };
  }

  Employee toEntity() {
    return Employee(
      id: id,
      name: name,
      email: email,
      phone: phone,
      roleId: roleId,
      depId: depId,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }
}