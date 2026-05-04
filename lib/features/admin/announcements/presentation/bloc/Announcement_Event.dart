import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

abstract class AnnouncementEvent {}

class LoadAnnouncements extends AnnouncementEvent {}

class CreateAnnouncementEvent extends AnnouncementEvent {
  final Announcement announcement;

  CreateAnnouncementEvent(this.announcement);
}