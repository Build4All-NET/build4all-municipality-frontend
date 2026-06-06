import 'package:flutter/material.dart';
import 'package:baladiyati/common/widgets/shimmer_loading.dart';
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
  final bool isLoading;

  const RecentRequestsSection({
    super.key,
    required this.requests,
    required this.onViewAll,
    required this.onRequestTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
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

        if (isLoading && requests.isEmpty) ...[
          const _RecentRequestSkeleton(),
          const _RecentRequestSkeleton(),
        ] else
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

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _RecentRequestSkeleton extends StatelessWidget {
  const _RecentRequestSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: 80, height: 24, radius: 12),
              const SizedBox(height: 8),
              Row(children: [
                const ShimmerBox(width: 12, height: 12, radius: 4),
                const SizedBox(width: 4),
                const ShimmerBox(width: 60, height: 11),
              ]),
            ],
          ),
          const ShimmerBox(width: 100, height: 14),
        ],
      ),
    );
  }
}

// ── Real card ─────────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final RecentRequestItem request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  static String _statusLabel(AppLocalizations l10n, String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT': return l10n.statusDraft;
      case 'SUBMITTED': return l10n.statusSubmitted;
      case 'UNDER_REVIEW': return l10n.statusUnderReview;
      case 'DOCUMENTS_MISSING': return l10n.statusDocumentsMissing;
      case 'IN_PROGRESS': return l10n.inProgress;
      case 'APPROVED': return l10n.approved;
      case 'REJECTED': return l10n.rejected;
      case 'COMPLETED': return l10n.completed;
      case 'CANCELLED': return l10n.statusCancelled;
      case 'TAX_PAID': return l10n.statusTaxPaid;
      case 'TAX_REJECTED': return l10n.statusTaxRejected;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final s = request.status.toUpperCase();
    final isError = s == 'REJECTED' || s == 'CANCELLED' ||
        s == 'TAX_REJECTED' || s == 'DOCUMENTS_MISSING';
    final badgeBackground =
        isError ? cs.error.withOpacity(0.10) : cs.primary.withOpacity(0.10);
    final badgeTextColor = isError ? cs.error : cs.primary;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(l10n, request.status),
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
                    Icon(Icons.access_time, size: 12, color: cs.outline),
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
