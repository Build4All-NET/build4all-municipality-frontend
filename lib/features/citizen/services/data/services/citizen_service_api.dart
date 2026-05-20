import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/service_model.dart';

class CitizenServiceApi {
  final Dio _dio;

  CitizenServiceApi({Dio? dio}) : _dio = dio ?? DioClient.muni;

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _dio.get('/api/services');
      final data = response.data;
      final List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
          .toList();
    } on DioException catch (e) {
      final msg = _extractMessage(e) ?? 'Failed to load services';
      throw AppException(msg);
    }
  }

  Future<ServiceModel> getServiceById(int id) async {
    try {
      final response = await _dio.get('/api/services/$id');
      return ServiceModel.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      final msg = _extractMessage(e) ?? 'Failed to load service';
      throw AppException(msg);
    }
  }

  String? _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return (data['message'] ?? data['error'])?.toString();
    }
    return null;
  }
}
