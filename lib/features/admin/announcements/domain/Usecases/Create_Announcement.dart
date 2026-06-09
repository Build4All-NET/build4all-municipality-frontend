import 'package:baladiyati/features/admin/announcements/domain/Repository/announcement_Repository.dart';
import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

class CreateAnnouncement {
  final AnnouncementRepository repo;

  CreateAnnouncement(this.repo);

  Future<Announcement> call(Announcement announcement) {
    return repo.create(announcement);
  }
}