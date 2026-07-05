import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetMyNotifications {
  final NotificationRepository repository;
  const GetMyNotifications(this.repository);

  Future<List<NotificationEntity>> call({bool unreadOnly = false}) =>
      repository.getMyNotifications(unreadOnly: unreadOnly);
}
