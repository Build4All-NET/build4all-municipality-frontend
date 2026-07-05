import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/citizen/notifications/domain/entities/notification_entity.dart';
import 'package:baladiyati/features/citizen/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:baladiyati/features/citizen/notifications/presentation/bloc/notifications_event.dart';
import 'package:baladiyati/features/citizen/notifications/presentation/bloc/notifications_state.dart';
import 'package:baladiyati/features/citizen/notifications/data/services/notification_api_service.dart';
import 'package:baladiyati/features/citizen/notifications/data/repositories/notification_repository_impl.dart';
import 'package:baladiyati/features/citizen/notifications/domain/usecases/get_my_notifications.dart';
import 'package:baladiyati/features/citizen/notifications/domain/usecases/mark_notification_read.dart';
import 'package:baladiyati/features/citizen/notifications/domain/usecases/mark_all_notifications_read.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc(
        getMyNotifications: GetMyNotifications(
          NotificationRepositoryImpl(NotificationApiService()),
        ),
        markNotificationRead: MarkNotificationRead(
          NotificationRepositoryImpl(NotificationApiService()),
        ),
        markAllNotificationsRead: MarkAllNotificationsRead(
          NotificationRepositoryImpl(NotificationApiService()),
        ),
      )..add(NotificationsLoadRequested()),
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, state),
                  if (state.isLoading && state.notifications.isEmpty)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.errorMessage != null &&
                      state.notifications.isEmpty)
                    _buildError(context)
                  else if (state.notifications.isEmpty)
                    _buildEmpty(context)
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => context
                            .read<NotificationsBloc>()
                            .add(NotificationsRefreshRequested()),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: state.notifications.length,
                          itemBuilder: (_, i) => _NotifCard(
                            item: state.notifications[i],
                            onTap: state.notifications[i].isRead
                                ? null
                                : () => context
                                    .read<NotificationsBloc>()
                                    .add(NotificationMarkReadRequested(
                                        state.notifications[i].id)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationsState state) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state.unreadCount > 0)
                TextButton.icon(
                  onPressed: () => context
                      .read<NotificationsBloc>()
                      .add(NotificationsMarkAllReadRequested()),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text(
                    l10n.markAllRead,
                    style: const TextStyle(fontSize: 13),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                children: [
                  Text(
                    l10n.notifications,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.loadFailed,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context
                    .read<NotificationsBloc>()
                    .add(NotificationsRefreshRequested()),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.noNotifications,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _notifIcon(String type) {
  switch (type.toLowerCase()) {
    case 'payment':
      return Icons.credit_card;
    case 'approved':
      return Icons.check_circle;
    default:
      return Icons.warning_amber_rounded;
  }
}

Color _notifIconBg(String type) {
  switch (type.toLowerCase()) {
    case 'payment':
      return const Color(0xFFFFF3E0);
    case 'approved':
      return const Color(0xFFE8F5E9);
    default:
      return const Color(0xFFFFFDE7);
  }
}

Color _notifIconColor(String type) {
  switch (type.toLowerCase()) {
    case 'payment':
      return Colors.orange;
    case 'approved':
      return Colors.green;
    default:
      return Colors.yellow.shade700;
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback? onTap;

  const _NotifCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = _notifIcon(item.type);
    final iconBg = _notifIconBg(item.type);
    final iconColor = _notifIconColor(item.type);
    final isUnread = !item.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isUnread
                ? Border.all(
                    color: const Color(0xFF2F6FED).withValues(alpha: 0.25))
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? const Color(0xFF2F6FED).withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isUnread ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isUnread) ...[
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F6FED),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2F6FED)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: isUnread ? 16 : 15,
                                  fontWeight: FontWeight.bold,
                                  color: isUnread
                                      ? const Color(0xFF1E3A5F)
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.body,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatDateTime(item.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isUnread
                                          ? const Color(0xFF2F6FED)
                                              .withValues(alpha: 0.7)
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: isUnread
                                        ? const Color(0xFF2F6FED)
                                            .withValues(alpha: 0.5)
                                        : Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 52,
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: iconColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(iconData, color: iconColor, size: 22),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F6FED),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
