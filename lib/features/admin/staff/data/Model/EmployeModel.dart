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
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      roleId: json['roleId'],
      depId: json['depId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "roleId": roleId,
      "depId": depId,
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
}