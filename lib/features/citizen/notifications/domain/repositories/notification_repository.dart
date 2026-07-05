import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getMyNotifications({bool unreadOnly = false});
  Future<NotificationEntity> markAsRead(int id);
  Future<void> markAllAsRead();
}
