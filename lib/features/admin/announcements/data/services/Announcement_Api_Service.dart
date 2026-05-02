import 'package:baladiyati/features/admin/announcements/data/model/announcementModel.dart';

import 'package:dio/dio.dart';

class AnnouncementApiService {
  final Dio dio;

  AnnouncementApiService(this.dio);

  Future<void> createAnnouncement(AnnouncementModel model) async {
    await dio.post(
      "/api/admin/announcements",
      data: model.toJson(),
    );
  }

  Future<List<AnnouncementModel>> getAll() async {
    final res = await dio.get("/api/admin/announcements");

    return (res.data as List)
        .map((e) => AnnouncementModel.fromJson(e))
        .toList();
  }
}