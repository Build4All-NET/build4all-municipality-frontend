// lib/features/citizen/home/data/services/announcement_service.dart

import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final Dio _dio;

  AnnouncementService() : _dio = DioClient.muni;

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final res = await _dio.get('/api/announcements');
    return (res.data as List)
        .map((e) => AnnouncementModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
