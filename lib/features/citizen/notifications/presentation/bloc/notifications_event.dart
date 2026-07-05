abstract class NotificationsEvent {}

class NotificationsLoadRequested extends NotificationsEvent {}

class NotificationsRefreshRequested extends NotificationsEvent {}

class NotificationMarkReadRequested extends NotificationsEvent {
  final int id;
  NotificationMarkReadRequested(this.id);
}

class NotificationsMarkAllReadRequested extends NotificationsEvent {}
