import 'package:baladiyati/features/admin/Departement/domain/Repository/Departement_Repository.dart';

class DeleteDepartment {
  final DepartmentRepository repo;

  DeleteDepartment(this.repo);

  Future<void> call(int id) {
    return repo.delete(id);
  }
}