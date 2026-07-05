import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../services/notification_api_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApiService _api;

  NotificationRepositoryImpl(this._api);

  @override
  Future<List<NotificationEntity>> getMyNotifications({bool unreadOnly = false}) =>
      _api.getMyNotifications(unreadOnly: unreadOnly);

  @override
  Future<NotificationEntity> markAsRead(int id) => _api.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _api.markAllAsRead();
}
