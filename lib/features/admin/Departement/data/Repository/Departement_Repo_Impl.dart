import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Repository/Departement_Repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentApiService api;

  DepartmentRepositoryImpl(this.api);

  @override
  Future<List<Department>> getAll() => api.getAll();

  @override
  Future<Department> getById(int id) async {
    final res = await api.dio.get('/api/admin/departments/$id');
    return DepartmentModel.fromJson(res.data);
  }

  @override
  Future<void> create(Department department) {
    return api.create(department as DepartmentModel);
  }

  @override
  Future<void> update(int id, Department department) {
    return api.update(id, department as DepartmentModel);
  }

  @override
  Future<void> delete(int id) {
    return api.delete(id);
  }
}