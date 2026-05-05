import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:dio/dio.dart';

class ServiceApiService {
  final Dio dio;

  ServiceApiService(this.dio);

  Future<List<ServiceModel>> getDepartments() async {
    final res = await dio.get("/api/services");

    return (res.data as List)
        .map((e) => ServiceModel.fromJson(e))
        .toList();
  }

  Future<void> create(ServiceModel model) async {
    await dio.post("/api/services", data: model.toJson());
  }

  Future<void> delete(int id) async {
    await dio.delete("/api/services/$id");
  }

  Future<void> update(int id, ServiceModel model) async {
    await dio.put("/api/services/$id", data: model.toJson());
  }
}