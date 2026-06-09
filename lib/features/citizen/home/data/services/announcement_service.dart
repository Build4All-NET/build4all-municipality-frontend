import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final Dio _dio;

  AnnouncementService() : _dio = DioClient.muni;

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final res = await _dio.get('/api/announcements');
      final data = res.data;
      List<dynamic> items;
      if (data is List) {
        items = data;
      } else if (data is Map) {
        final inner = data['data'] ??
            data['content'] ??
            data['announcements'] ??
            data['items'];
        items = inner is List ? inner : [];
      } else {
        items = [];
      }
      return items
          .whereType<Map>()
          .map((e) => AnnouncementModel.fromJson(
              Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
