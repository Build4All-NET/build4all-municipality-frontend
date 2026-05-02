import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

abstract class AnnouncementState {}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> list;

  AnnouncementLoaded(this.list);
}

class AnnouncementError extends AnnouncementState {
  final String message;

  AnnouncementError(this.message);
}