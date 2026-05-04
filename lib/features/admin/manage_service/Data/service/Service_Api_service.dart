import 'package:dio/dio.dart';
import '../model/service_model.dart';

class ServiceApiService {
  final Dio dio;

  ServiceApiService(this.dio);

  Future<List<ServiceModel>> getServices() async {
    final res = await dio.get("/api/services");

    return (res.data as List)
        .map((e) => ServiceModel.fromJson(e))
        .toList();
  }

  Future<void> createService(ServiceModel service) async {
    await dio.post(
      "/api/services",
      data: service.toJson(),
    );
  }

  Future<void> deleteService(int id) async {
    await dio.delete("/api/services/$id");
  }
}