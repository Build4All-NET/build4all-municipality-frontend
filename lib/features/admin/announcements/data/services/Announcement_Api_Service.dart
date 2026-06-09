import 'package:baladiyati/features/admin/announcements/data/model/announcementModel.dart';
import 'package:dio/dio.dart';

class AnnouncementApiService {
  final Dio dio;

  AnnouncementApiService(this.dio);

  Future<List<AnnouncementModel>> getAll() async {
    final res = await dio.get('/api/admin/announcements');

    final data = res.data;
    if (data is! List) {
      throw Exception('Invalid announcements response');
    }

    return data
        .map((e) => AnnouncementModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AnnouncementModel> getById(int id) async {
    final res = await dio.get('/api/admin/announcements/$id');

    return AnnouncementModel.fromJson(
      Map<String, dynamic>.from(res.data),
    );
  }

  Future<AnnouncementModel> createAnnouncement(
    AnnouncementModel model,
  ) async {
    final res = await dio.post(
      '/api/admin/announcements',
      data: model.toJson(),
    );

    return AnnouncementModel.fromJson(
      Map<String, dynamic>.from(res.data),
    );
  }

  Future<AnnouncementModel> updateAnnouncement(
    int id,
    AnnouncementModel model,
  ) async {
    final res = await dio.put(
      '/api/admin/announcements/$id',
      data: model.toJson(),
    );

    return AnnouncementModel.fromJson(
      Map<String, dynamic>.from(res.data),
    );
  }

  Future<void> deleteAnnouncement(int id) async {
    await dio.delete('/api/admin/announcements/$id');
  }
}