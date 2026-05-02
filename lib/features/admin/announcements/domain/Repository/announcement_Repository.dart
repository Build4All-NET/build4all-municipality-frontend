import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<void> create(Announcement a);
  Future<List<Announcement>> getAll();
}