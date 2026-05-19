import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/request_model.dart';

class RequestApiService {
  final Dio _dio;

  RequestApiService({Dio? dio}) : _dio = dio ?? DioClient.muni;

  Future<List<RequestModel>> getMyRequests() async {
    try {
      final response = await _dio.get('/api/requests');
      final data = response.data;
      final List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is Map && data['requests'] is List) {
        list = data['requests'] as List;
      } else {
        list = [];
      }
      return list.whereType<Map<String, dynamic>>().map(RequestModel.fromJson).toList();
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to load requests');
    }
  }

  Future<RequestModel> getRequestById(String id) async {
    try {
      final response = await _dio.get('/api/requests/$id');
      return RequestModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to load request');
    }
  }

  Future<RequestModel> createRequest({
    required int serviceId,
    required String title,
    required String description,
    String? addressText,
    double? geoLat,
    double? geoLng,
    List<String>? attachmentUrls,
  }) async {
    try {
      List<Map<String, dynamic>>? attachments;
      if (attachmentUrls != null && attachmentUrls.isNotEmpty) {
        attachments = attachmentUrls.map((url) {
          final fileName = url.split('/').last;
          final ext = fileName.split('.').last.toLowerCase();
          final fileType = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)
              ? 'image'
              : ext == 'pdf'
                  ? 'pdf'
                  : 'document';
          return {'fileName': fileName, 'fileUrl': url, 'fileType': fileType};
        }).toList();
      }

      final body = {
        'title': title,
        'description': description,
        if (addressText != null && addressText.isNotEmpty) 'addressText': addressText,
        if (geoLat != null) 'geoLat': geoLat,
        if (geoLng != null) 'geoLng': geoLng,
        if (attachments != null) 'attachments': attachments,
      };

      final response = await _dio.post('/api/requests/$serviceId', data: body);
      return RequestModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to create request');
    }
  }

  String? _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) return (data['message'] ?? data['error'])?.toString();
    return null;
  }
}
