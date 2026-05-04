import 'package:baladiyati/features/admin/announcements/domain/Repository/announcement_Repository.dart';
import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

class GetAnnouncements {
  final AnnouncementRepository repo;

  GetAnnouncements(this.repo);

  Future<List<Announcement>> call() {
    return repo.getAll();
  }
}