import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAll();

  Future<Announcement> getById(int id);

  Future<Announcement> create(Announcement announcement);

  Future<Announcement> update(int id, Announcement announcement);

  Future<void> delete(int id);
}