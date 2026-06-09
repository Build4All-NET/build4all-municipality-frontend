import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Repository/Departement_Repository.dart';

class AddDepartment {
  final DepartmentRepository repo;

  AddDepartment(this.repo);

  Future<void> call(Department dep) {
    return repo.add(dep);
  }
}