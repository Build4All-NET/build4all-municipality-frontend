import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';

abstract class DepartmentRepository {
  Future<List<Department>> getAll();
  Future<Department> getById(int id);
  Future<void> create(Department department);
  Future<void> update(int id, Department department);
  Future<void> delete(int id);
}