// lib/features/citizen/notifications/presentation/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final notifications = [
      _NotificationItem(
        id: '1',
        type: _NotifType.payment,
        titleAr: 'دفعة مستحقة',
        messageAr: 'لديك دفعة مستحقة لطلب براءة ذمة بلدية',
        time: 'منذ ساعة',
        read: false,
      ),
      _NotificationItem(
        id: '2',
        type: _NotifType.approved,
        titleAr: 'تمت الموافقة',
        messageAr: 'تمت الموافقة على طلب ترخيص المحل التجاري',
        time: 'منذ يومين',
        read: true,
      ),
      _NotificationItem(
        id: '3',
        type: _NotifType.missingDocs,
        titleAr: 'مستندات ناقصة',
        messageAr: 'يرجى تقديم المستندات المطلوبة لطلب رخصة البناء',
        time: 'منذ ٣ أيام',
        read: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.notifications,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (_, i) {
                  return _NotifCard(item: notifications[i]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NotifType { payment, approved, missingDocs }

class _NotificationItem {
  final String id, titleAr, messageAr, time;
  final _NotifType type;
  final bool read;

  const _NotificationItem({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.messageAr,
    required this.time,
    required this.read,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotificationItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final iconData = item.type == _NotifType.payment
        ? Icons.credit_card
        : item.type == _NotifType.approved
            ? Icons.check_circle
            : Icons.warning_amber_rounded;

    final iconBg = item.type == _NotifType.payment
        ? const Color(0xFFFFF3E0)
        : item.type == _NotifType.approved
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFFDE7);

    final iconColor = item.type == _NotifType.payment
        ? Colors.orange
        : item.type == _NotifType.approved
            ? Colors.green
            : Colors.yellow.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.read ? Colors.white : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: item.read
            ? Border.all(color: Colors.transparent)
            : Border.all(color: const Color(0xFF2F6FED).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            if (!item.read) ...[
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F6FED),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.titleAr,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.messageAr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
