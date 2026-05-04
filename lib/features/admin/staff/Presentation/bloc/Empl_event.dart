import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';

abstract class EmployeeEvent {}

class LoadEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final Employee employee;

  AddEmployee(this.employee);
}