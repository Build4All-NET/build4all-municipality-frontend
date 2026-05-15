import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Domain/Repository/Employe_Repo.dart';

class UpdateEmployeeUsecase {
  final EmployeeRepository repository;

  UpdateEmployeeUsecase(this.repository);

  Future<void> call(int id, Employee employee) {
    return repository.updateEmployee(id, employee);
  }
}
