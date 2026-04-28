// lib/features/citizen/home/presentation/widgets/recent_requests.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class RecentRequestItem {
  final String id;
  final String nameAr;
  final String status;
  final String date;

  const RecentRequestItem({
    required this.id,
    required this.nameAr,
    required this.status,
    required this.date,
  });
}

class RecentRequestsSection extends StatelessWidget {
  final List<RecentRequestItem> requests;
  final VoidCallback onViewAll;
  final Function(RecentRequestItem) onRequestTap;

  const RecentRequestsSection({
    super.key,
    required this.requests,
    required this.onViewAll,
    required this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // Section header.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                l10n.viewAll,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              l10n.recentRequests,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...requests.map(
          (request) => _RequestCard(
            request: request,
            onTap: () => onRequestTap(request),
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RecentRequestItem request;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWaitingPayment = request.status == 'waiting_payment';
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final badgeBackground = isWaitingPayment
        ? cs.error.withOpacity(0.10)
        : cs.primary.withOpacity(0.10);

    final badgeTextColor = isWaitingPayment ? cs.error : cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date + status badge.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isWaitingPayment ? 'بانتظار الدفع' : 'قيد التدقيق',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: badgeTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: cs.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: cs.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Text(
              request.nameAr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}