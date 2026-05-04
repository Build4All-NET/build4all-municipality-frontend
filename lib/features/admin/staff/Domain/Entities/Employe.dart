class Employee {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final int roleId;
  final int depId;

  Employee({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.roleId,
    required this.depId,
  });
}