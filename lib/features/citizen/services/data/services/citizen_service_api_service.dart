import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';

import '../models/citizen_service_model.dart';

class CitizenServiceApiService {
  final Dio _dio;

  CitizenServiceApiService({
    Dio? dio,
  }) : _dio = dio ?? DioClient.muni;

  Future<List<CitizenServiceModel>> getCitizenServices() async {
    final response = await _dio.get('/api/services');

    final list = _extractList(response.data);

    return list
        .whereType<Map<String, dynamic>>()
        .map(CitizenServiceModel.fromJson)
        .where((service) => service.isActive)
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return data['data'] as List;
      if (data['services'] is List) return data['services'] as List;
      if (data['items'] is List) return data['items'] as List;
      if (data['content'] is List) return data['content'] as List;
    }

    return [];
  }
}