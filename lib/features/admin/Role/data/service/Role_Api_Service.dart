import 'package:baladiyati/features/admin/Role/data/model/RoleModel.dart';
import 'package:dio/dio.dart';

class RoleApiService {
  final Dio dio;

  RoleApiService(this.dio);

  Future<List<RoleModel>> getRoles() async {
    final res = await dio.get("/api/admin/roles/all");

    return (res.data as List)
        .map((e) => RoleModel.fromJson(e))
        .toList();
  }
}