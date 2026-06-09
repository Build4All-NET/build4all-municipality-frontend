import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class AdminProfileApiService {
  final Dio dio;

  AdminProfileApiService({Dio? dio}) : dio = dio ?? DioClient.build;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await dio.get('/admin/users/me');

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw AppException('Invalid server response.');
  }
}