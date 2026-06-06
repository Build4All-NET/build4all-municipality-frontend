import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class AiService {
  AiService({Dio? dio}) : _dio = dio ?? DioClient.muni;

  final Dio _dio;

  Future<String> getServiceExplanation(int serviceId) async {
    final response = await _dio.get('/api/ai/service/$serviceId');
    final data = response.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data as Map);
      return map['reply']?.toString() ??
          map['explanation']?.toString() ??
          map['content']?.toString() ??
          map['message']?.toString() ??
          data.toString();
    }
    if (data is String) return data;
    return data.toString();
  }
}
