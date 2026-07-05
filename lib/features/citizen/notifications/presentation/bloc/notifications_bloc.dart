import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/features/citizen/notifications/domain/usecases/get_my_notifications.dart';
import 'package:baladiyati/features/citizen/notifications/domain/usecases/mark_notification_read.dart';
import 'package:baladiyati/features/citizen/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:baladiyati/features/citizen/notifications/data/repositories/notification_repository_impl.dart';
import 'package:baladiyati/features/citizen/notifications/data/services/notification_api_service.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetMyNotifications _getMyNotifications;
  final MarkNotificationRead _markNotificationRead;
  final MarkAllNotificationsRead _markAllNotificationsRead;

  NotificationsBloc({
    GetMyNotifications? getMyNotifications,
    MarkNotificationRead? markNotificationRead,
    MarkAllNotificationsRead? markAllNotificationsRead,
  })  : _getMyNotifications = getMyNotifications ??
            GetMyNotifications(NotificationRepositoryImpl(NotificationApiService())),
        _markNotificationRead = markNotificationRead ??
            MarkNotificationRead(NotificationRepositoryImpl(NotificationApiService())),
        _markAllNotificationsRead = markAllNotificationsRead ??
            MarkAllNotificationsRead(NotificationRepositoryImpl(NotificationApiService())),
        super(const NotificationsState()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationsRefreshRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onLoad(
      NotificationsEvent event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final notifications = await _getMyNotifications();
      emit(state.copyWith(isLoading: false, notifications: notifications));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> _onMarkRead(
      NotificationMarkReadRequested event, Emitter<NotificationsState> emit) async {
    try {
      final updated = await _markNotificationRead.call(event.id);
      final list = state.notifications.map((n) {
        if (n.id == event.id) return updated;
        return n;
      }).toList();
      emit(state.copyWith(notifications: list));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  Future<void> _onMarkAllRead(
      NotificationsMarkAllReadRequested event, Emitter<NotificationsState> emit) async {
    try {
      await _markAllNotificationsRead.call();
      final list = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(state.copyWith(notifications: list));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
