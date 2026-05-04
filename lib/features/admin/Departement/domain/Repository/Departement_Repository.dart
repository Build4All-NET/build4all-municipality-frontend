import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';

abstract class DepartmentRepository {
  Future<List<Department>> getAll();
  Future<void> add(Department dep);
  Future<void> update(Department dep);
  Future<void> delete(int id);
}