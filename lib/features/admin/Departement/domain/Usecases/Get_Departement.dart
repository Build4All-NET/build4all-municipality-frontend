import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Repository/Departement_Repository.dart';

class GetDepartments {
  final DepartmentRepository repository;

  GetDepartments(this.repository);

  Future<List<Department>> call() {
    return repository.getAll();
  }
}