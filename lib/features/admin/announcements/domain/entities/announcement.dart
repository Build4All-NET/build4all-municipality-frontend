class Announcement {
  final int? id;
  final String title;
  final String content;
  final DateTime? createdAt;

  const Announcement({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
  });
}