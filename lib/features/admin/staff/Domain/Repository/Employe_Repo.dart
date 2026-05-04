import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';


abstract class EmployeeRepository {
  Future<List<Employee>> getEmployees();
  Future<void> createEmployee(Employee employee);
}