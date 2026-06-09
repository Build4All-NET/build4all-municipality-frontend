import 'package:baladiyati/features/admin/staff/Domain/Repository/Employe_Repo.dart';

class DeleteEmployeeUsecase {
  final EmployeeRepository repository;

  DeleteEmployeeUsecase(this.repository);

  Future<void> call(int id) {
    return repository.deleteEmployee(id);
  }
}
