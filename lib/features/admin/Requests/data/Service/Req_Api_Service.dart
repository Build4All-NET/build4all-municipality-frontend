import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:dio/dio.dart';

class RequestApiService {
  final Dio dio;

  RequestApiService(this.dio);

  /// CREATE
  Future<void> createRequest(RequestModel request) async {
    await dio.post(
      "/api/requests",
      data: request.toJson(),
    );
  }

  /// GET ALL
  Future<List<RequestModel>> getRequests({
  int? departmentId,
  String? status,
}) async {
  final res = await dio.get(
    '/api/requests',
    queryParameters: {
      if (departmentId != null) 'departmentId': departmentId,
      if (status != null) 'status': status,
    },
  );

  return (res.data as List)
      .map((e) => RequestModel.fromJson(e))
      .toList();
}
  /// GET ONE
  Future<RequestModel> getRequest(int id) async {
    final res = await dio.get("/api/requests/$id");

    return RequestModel.fromJson(res.data);
  }

  /// UPDATE
  Future<void> updateRequest(int id, RequestModel request) async {
    await dio.put(
      "/api/requests/$id",
      data: request.toJson(),
    );
  }

  /// DELETE
  Future<void> deleteRequest(int id) async {
    await dio.delete("/api/requests/$id");
  }

  /// ADMIN GET ALL
  Future<List<RequestModel>> getAllRequestsAdmin() async {
    final res = await dio.get("/api/admin/requests");

    return (res.data as List)
        .map((e) => RequestModel.fromJson(e))
        .toList();
  }

  /// ADMIN UPDATE STATUS
  Future<void> updateStatus(int id, String status) async {
    await dio.put(
      "/api/admin/requests/$id/status",
      data: {"status": status},
    );
  }
}