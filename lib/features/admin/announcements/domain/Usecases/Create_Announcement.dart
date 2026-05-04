import 'package:baladiyati/features/admin/announcements/domain/Repository/announcement_Repository.dart';
import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

class CreateAnnouncement {
  final AnnouncementRepository repo;

  CreateAnnouncement(this.repo);

  Future<void> call(Announcement a) {
    return repo.create(a);
  }
}