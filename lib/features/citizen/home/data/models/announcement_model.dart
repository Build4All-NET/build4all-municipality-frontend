// lib/features/citizen/home/data/models/announcement_model.dart

class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final DateTime? createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
