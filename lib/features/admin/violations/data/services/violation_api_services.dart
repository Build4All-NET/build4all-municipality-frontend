import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/violations/data/model/ViolationModel.dart';
import 'package:dio/dio.dart';

class ViolationApiService {
  final Dio dio;

  ViolationApiService({Dio? dio}) : dio = dio ?? DioClient.muni;

  Future<List<ViolationModel>> getAllViolations() async {
    final response = await dio.get('/api/violations/all');

    final data = response.data;

    if (data is! List) {
      throw Exception('Invalid violations response');
    }

    return data
        .map((e) => ViolationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> createViolation(ViolationModel violation) async {
    await dio.post(
      '/api/admin/violations/create',
      data: violation.toJson(),
    );
  }

  Future<void> updateViolation(int id, ViolationModel violation) async {
    await dio.put(
      '/api/admin/violations/$id',
      data: violation.toJson(),
    );
  }

  Future<void> deleteViolation(int id) async {
    await dio.delete('/api/admin/violations/$id');
  }
}