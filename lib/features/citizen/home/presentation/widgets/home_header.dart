// lib/features/citizen/home/presentation/widgets/home_header.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String municipality;
  final int notificationCount;
  final int activeRequests;
  final int awaitingPayment;
  final int completed;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.municipality,
    required this.notificationCount,
    required this.activeRequests,
    required this.awaitingPayment,
    required this.completed,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      // 🔥 Gradient now uses dynamic theme colors instead of hardcoded
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.9),
            cs.primary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),

      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),

      child: Column(
        children: [
          // 🔹 Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔔 Notification icon
              GestureDetector(
                onTap: onNotificationTap,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // instead of white → use onPrimary with opacity
                        color: cs.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: cs.onPrimary,
                        size: 24,
                      ),
                    ),

                    if (notificationCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: cs.error, // 🔥 was Colors.red
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: cs.onError,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 👤 User info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.welcomeMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onPrimary.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    userName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    municipality,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 📊 Stats row
          Row(
            children: [
              _StatCard(
                value: '$activeRequests',
                label: l10n.activeRequests,
                icon: Icons.description_outlined,
              ),
              const SizedBox(width: 10),
              _StatCard(
                value: '$awaitingPayment',
                label: l10n.awaitingPayment,
                icon: Icons.error_outline,
              ),
              const SizedBox(width: 10),
              _StatCard(
                value: '$completed',
                label: l10n.completed,
                icon: Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),

        decoration: BoxDecoration(
          color: cs.onPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          children: [
            Icon(icon, color: cs.onPrimary, size: 20),

            const SizedBox(height: 6),

            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}