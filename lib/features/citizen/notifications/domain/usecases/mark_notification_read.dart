import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationRead {
  final NotificationRepository repository;
  const MarkNotificationRead(this.repository);

  Future<NotificationEntity> call(int id) => repository.markAsRead(id);
}
