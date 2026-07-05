class NotificationEntity {
  final int id;
  final int? municipalityId;
  final int? userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    this.municipalityId,
    this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: (json['id'] as num).toInt(),
      municipalityId: (json['municipalityId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      municipalityId: municipalityId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
