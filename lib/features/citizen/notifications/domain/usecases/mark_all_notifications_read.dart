import '../repositories/notification_repository.dart';

class MarkAllNotificationsRead {
  final NotificationRepository repository;
  const MarkAllNotificationsRead(this.repository);

  Future<void> call() => repository.markAllAsRead();
}
