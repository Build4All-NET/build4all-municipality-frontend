class Employee {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final int roleId;
  final int depId;
  final String? roleName;
  final String? departmentName;

  Employee({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.roleId = 0,
    this.depId = 0,
    this.roleName,
    this.departmentName,
  });
}
