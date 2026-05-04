import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Domain/Repository/Employe_Repo.dart';

class CreateEmployee {
  final EmployeeRepository repository;

  CreateEmployee(this.repository);

  Future<void> call(Employee employee) async {
    return await repository.createEmployee(employee);
  }
}