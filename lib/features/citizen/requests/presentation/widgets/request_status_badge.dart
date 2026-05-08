// lib/features/citizen/requests/presentation/widgets/request_status_badge.dart

import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum CitizenRequestStatus {
  draft,
  submitted,
  underReview,
  waitingPayment,
  approved,
  inField,
  delivered,
  rejected,
  cancelled,
}

CitizenRequestStatus requestStatusFromString(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'draft':
      return CitizenRequestStatus.draft;

    case 'submitted':
      return CitizenRequestStatus.submitted;

    case 'under_review':
    case 'underreview':
    case 'review':
    case 'in_review':
      return CitizenRequestStatus.underReview;

    case 'waiting_payment':
    case 'waitingpayment':
    case 'payment':
      return CitizenRequestStatus.waitingPayment;

    case 'approved':
      return CitizenRequestStatus.approved;

    case 'in_field':
    case 'infield':
    case 'field':
      return CitizenRequestStatus.inField;

    case 'delivered':
    case 'completed':
    case 'done':
      return CitizenRequestStatus.delivered;

    case 'rejected':
      return CitizenRequestStatus.rejected;

    case 'cancelled':
    case 'canceled':
      return CitizenRequestStatus.cancelled;

    default:
      return CitizenRequestStatus.submitted;
  }
}

String requestStatusLabel(
  AppLocalizations l10n,
  CitizenRequestStatus status,
) {
  switch (status) {
    case CitizenRequestStatus.draft:
      return l10n.statusDraft;
    case CitizenRequestStatus.submitted:
      return l10n.statusSubmitted;
    case CitizenRequestStatus.underReview:
      return l10n.statusUnderReview;
    case CitizenRequestStatus.waitingPayment:
      return l10n.statusWaitingPayment;
    case CitizenRequestStatus.approved:
      return l10n.statusApproved;
    case CitizenRequestStatus.inField:
      return l10n.statusInField;
    case CitizenRequestStatus.delivered:
      return l10n.statusDelivered;
    case CitizenRequestStatus.rejected:
      return l10n.statusRejected;
    case CitizenRequestStatus.cancelled:
      return l10n.statusCancelled;
  }
}

class RequestStatusBadge extends StatelessWidget {
  final String status;

  const RequestStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final parsedStatus = requestStatusFromString(status);

    final Color bgColor = _backgroundColor(cs, parsedStatus);
    final Color textColor = _textColor(cs, parsedStatus);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.paddingSmall / 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Text(
        requestStatusLabel(l10n, parsedStatus),
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _backgroundColor(
    ColorScheme cs,
    CitizenRequestStatus status,
  ) {
    switch (status) {
      case CitizenRequestStatus.draft:
        return cs.surfaceVariant.withOpacity(0.60);
      case CitizenRequestStatus.submitted:
        return cs.primary.withOpacity(0.10);
      case CitizenRequestStatus.underReview:
        return Colors.amber.withOpacity(0.15);
      case CitizenRequestStatus.waitingPayment:
        return Colors.orange.withOpacity(0.15);
      case CitizenRequestStatus.approved:
        return Colors.green.withOpacity(0.15);
      case CitizenRequestStatus.inField:
        return Colors.purple.withOpacity(0.12);
      case CitizenRequestStatus.delivered:
        return Colors.teal.withOpacity(0.14);
      case CitizenRequestStatus.rejected:
        return cs.error.withOpacity(0.12);
      case CitizenRequestStatus.cancelled:
        return cs.error.withOpacity(0.10);
    }
  }

  Color _textColor(
    ColorScheme cs,
    CitizenRequestStatus status,
  ) {
    switch (status) {
      case CitizenRequestStatus.draft:
        return cs.onSurfaceVariant;
      case CitizenRequestStatus.submitted:
        return cs.primary;
      case CitizenRequestStatus.underReview:
        return Colors.amber.shade800;
      case CitizenRequestStatus.waitingPayment:
        return Colors.orange.shade800;
      case CitizenRequestStatus.approved:
        return Colors.green.shade700;
      case CitizenRequestStatus.inField:
        return Colors.purple.shade700;
      case CitizenRequestStatus.delivered:
        return Colors.teal.shade700;
      case CitizenRequestStatus.rejected:
        return cs.error;
      case CitizenRequestStatus.cancelled:
        return cs.error;
    }
  }
}