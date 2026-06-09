import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';

abstract class EmployeeEvent {}

class LoadEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final Employee employee;
  AddEmployee(this.employee);
}

class UpdateEmployee extends EmployeeEvent {
  final int id;
  final Employee employee;
  UpdateEmployee({required this.id, required this.employee});
}

class DeleteEmployee extends EmployeeEvent {
  final int id;
  DeleteEmployee(this.id);
}

class SearchEmployees extends EmployeeEvent {
  final String query;
  SearchEmployees(this.query);
}
