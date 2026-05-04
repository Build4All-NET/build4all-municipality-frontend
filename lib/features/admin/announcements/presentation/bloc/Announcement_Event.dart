import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

abstract class AnnouncementEvent {}

class LoadAnnouncements extends AnnouncementEvent {}

class CreateAnnouncementEvent extends AnnouncementEvent {
  final Announcement announcement;

  CreateAnnouncementEvent(this.announcement);
}

class UpdateAnnouncementEvent extends AnnouncementEvent {
  final int id;
  final Announcement announcement;

  UpdateAnnouncementEvent({
    required this.id,
    required this.announcement,
  });
}

class DeleteAnnouncementEvent extends AnnouncementEvent {
  final int id;

  DeleteAnnouncementEvent(this.id);
}