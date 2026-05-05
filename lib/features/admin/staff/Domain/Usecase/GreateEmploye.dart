import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Domain/Repository/Employe_Repo.dart';

class CreateEmployee {
  final EmployeeRepository repository;

  CreateEmployee(this.repository);

  Future<void> call(Employee employee) {
    return repository.createEmployee(employee);
  }
}