import 'package:dio/dio.dart';

class RoleApiService {
  final Dio dio;

  RoleApiService(this.dio);

  Future<List<dynamic>> getAll() async {
    final res = await dio.get("/api/admin/roles/all");
    return res.data;
  }
}