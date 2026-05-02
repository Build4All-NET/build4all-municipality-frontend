import 'package:baladiyati/features/admin/announcements/data/model/announcementModel.dart';

import 'package:baladiyati/features/admin/announcements/data/services/Announcement_Api_Service.dart';
import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

class AnnouncementRepositoryImpl {
  final AnnouncementApiService api;

  AnnouncementRepositoryImpl(this.api);

  Future<void> create(Announcement a) {
    final model = AnnouncementModel(
      title: a.title,
      content: a.content,
    );

    return api.createAnnouncement(model);
  }

  Future<List<Announcement>> getAll() async {
    final result = await api.getAll();

    return result; // إذا بدك لاحقاً ممكن تحوّل لـ Entity
  }
}