import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Repository/Departement_Repository.dart';

class UpdateDepartment {
  final DepartmentRepository repo;

  UpdateDepartment(this.repo);

  Future<void> call(Department dep) {
    return repo.update(dep);
  }
}