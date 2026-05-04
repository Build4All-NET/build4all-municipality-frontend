import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:dio/dio.dart';

class DepartmentApiService {
  final Dio dio;

  DepartmentApiService(this.dio);

  Future<List<DepartmentModel>> getAll() async {
    final res = await dio.get("/departments/all");
    return (res.data as List)
        .map((e) => DepartmentModel.fromJson(e))
        .toList();
  }

  Future<void> add(DepartmentModel model) async {
    await dio.post("/departments/create", data: model.toJson());
  }

  Future<void> update(int id, DepartmentModel model) async {
    await dio.put("/departments/$id", data: model.toJson());
  }

  Future<void> delete(int id) async {
    await dio.delete("/departments/$id");
  }
}