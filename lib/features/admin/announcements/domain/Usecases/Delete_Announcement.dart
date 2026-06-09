import 'package:baladiyati/features/admin/announcements/domain/Repository/announcement_Repository.dart';

class DeleteAnnouncement {
  final AnnouncementRepository repo;

  DeleteAnnouncement(this.repo);

  Future<void> call(int id) {
    return repo.delete(id);
  }
}