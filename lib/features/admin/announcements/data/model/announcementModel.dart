import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  AnnouncementModel({
    required super.title,
    required super.content,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      title: json["title"],
      content: json["content"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
    };
  }
}