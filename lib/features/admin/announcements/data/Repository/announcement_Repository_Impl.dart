import 'package:baladiyati/features/admin/announcements/data/model/announcementModel.dart';
import 'package:baladiyati/features/admin/announcements/data/services/Announcement_Api_Service.dart';
import 'package:baladiyati/features/admin/announcements/domain/Repository/announcement_Repository.dart';
import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementApiService api;

  AnnouncementRepositoryImpl(this.api);

  @override
  Future<List<Announcement>> getAll() async {
    return api.getAll();
  }

  @override
  Future<Announcement> getById(int id) {
    return api.getById(id);
  }

  @override
  Future<Announcement> create(Announcement announcement) {
    final model = AnnouncementModel.fromEntity(announcement);
    return api.createAnnouncement(model);
  }

  @override
  Future<Announcement> update(int id, Announcement announcement) {
    final model = AnnouncementModel.fromEntity(announcement);
    return api.updateAnnouncement(id, model);
  }

  @override
  Future<void> delete(int id) {
    return api.deleteAnnouncement(id);
  }
}