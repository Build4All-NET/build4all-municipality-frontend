import 'package:baladiyati/features/admin/announcements/domain/Repository/announcement_Repository.dart';
import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

class UpdateAnnouncement {
  final AnnouncementRepository repo;

  UpdateAnnouncement(this.repo);

  Future<Announcement> call(int id, Announcement announcement) {
    return repo.update(id, announcement);
  }
}