import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationApiService {
  final Dio _dio;

  NotificationApiService({Dio? dio}) : _dio = dio ?? DioClient.muni;

  Future<List<NotificationEntity>> getMyNotifications({bool unreadOnly = false}) async {
    try {
      final response = await _dio.get(
        '/api/notifications',
        queryParameters: {'unreadOnly': unreadOnly},
      );
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
          .map(NotificationEntity.fromJson)
          .toList();
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to load notifications');
    }
  }

  Future<NotificationEntity> markAsRead(int id) async {
    try {
      final response = await _dio.put('/api/notifications/$id/read');
      return NotificationEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('/api/notifications/read-all');
    } on DioException catch (e) {
      throw AppException(_extractMessage(e) ?? 'Failed to mark all as read');
    }
  }

  String? _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) return (data['message'] ?? data['error'])?.toString();
    return null;
  }
}
