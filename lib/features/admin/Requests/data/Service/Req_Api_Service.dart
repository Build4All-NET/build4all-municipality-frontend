import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:dio/dio.dart';

class RequestApiService {
  final Dio dio;

  RequestApiService(this.dio);

  Future<void> createRequest(RequestModel request) async {
    await dio.post(
      '/api/requests',
      data: request.toJson(),
    );
  }

  Future<List<RequestModel>> getRequests({
    int? departmentId,
    String? status,
  }) async {
    final res = await dio.get(
      '/api/requests',
      queryParameters: {
        if (departmentId != null) 'departmentId': departmentId,
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );

    return _parseList(res.data);
  }

  Future<RequestModel> getRequest(int id) async {
    final res = await dio.get('/api/requests/$id');
    return _parseOne(res.data);
  }

  Future<void> updateRequest(int id, RequestModel request) async {
    await dio.put(
      '/api/requests/$id',
      data: request.toJson(),
    );
  }

  Future<void> deleteRequest(int id) async {
    await dio.delete('/api/requests/$id');
  }

  Future<List<RequestModel>> getAllRequestsAdmin({
    int? departmentId,
    String? status,
  }) async {
    final res = await dio.get(
      '/api/admin/requests',
      queryParameters: {
        if (departmentId != null) 'departmentId': departmentId,
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );

    return _parseList(res.data);
  }

  Future<RequestModel> getRequestAdmin(int id) async {
    final res = await dio.get('/api/admin/requests/$id');
    return _parseOne(res.data);
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await dio.put(
        '/api/admin/requests/$id/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      // fallback if backend endpoint is PUT /api/admin/requests/{id}
      final code = e.response?.statusCode;
      if (code == 404 || code == 405) {
        await dio.put(
          '/api/admin/requests/$id',
          data: {'status': status},
        );
        return;
      }

      rethrow;
    }
  }

  List<RequestModel> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => RequestModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw AppException('Invalid server response.');
  }

  RequestModel _parseOne(dynamic data) {
    if (data is Map<String, dynamic>) {
      return RequestModel.fromJson(data);
    }

    if (data is Map) {
      return RequestModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw AppException('Invalid server response.');
  }
}