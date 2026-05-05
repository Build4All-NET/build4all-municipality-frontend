import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Repository/Departement_Repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentApiService api;

  DepartmentRepositoryImpl(this.api);

  @override
  Future<List<Department>> getAll() async {
    final result = await api.getAll();

    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> add(Department dep) async {
    await api.add(DepartmentModel.fromEntity(dep));
  }

  @override
  Future<void> update(Department dep) async {
    await api.update(dep.id, DepartmentModel.fromEntity(dep));
  }

  @override
  Future<void> delete(int id) async {
    await api.delete(id);
  }
}