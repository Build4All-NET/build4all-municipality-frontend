// lib/features/citizen/requests/presentation/screens/request_details_screen.dart

import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';
import 'package:baladiyati/features/citizen/requests/presentation/widgets/request_status_badge.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RequestDetailsScreen extends StatelessWidget {
  final RequestModel request;

  const RequestDetailsScreen({
    super.key,
    required this.request,
  });

  double _progressValue(CitizenRequestStatus status) {
    switch (status) {
      case CitizenRequestStatus.draft:
        return 0.10;
      case CitizenRequestStatus.submitted:
        return 0.25;
      case CitizenRequestStatus.underReview:
        return 0.45;
      case CitizenRequestStatus.inField:
        return 0.60;
      case CitizenRequestStatus.approved:
        return 0.75;
      case CitizenRequestStatus.waitingPayment:
        return 0.85;
      case CitizenRequestStatus.delivered:
        return 1.00;
      case CitizenRequestStatus.rejected:
      case CitizenRequestStatus.cancelled:
        return 1.00;
    }
  }

  List<CitizenRequestStatus> _timelineStatuses() {
    return const [
      CitizenRequestStatus.submitted,
      CitizenRequestStatus.underReview,
      CitizenRequestStatus.inField,
      CitizenRequestStatus.approved,
      CitizenRequestStatus.waitingPayment,
      CitizenRequestStatus.delivered,
    ];
  }

  bool _isCompletedStep(
    CitizenRequestStatus current,
    CitizenRequestStatus step,
  ) {
    final order = _timelineStatuses();

    if (current == CitizenRequestStatus.rejected ||
        current == CitizenRequestStatus.cancelled) {
      return false;
    }

    final currentIndex = order.indexOf(current);
    final stepIndex = order.indexOf(step);

    if (currentIndex == -1 || stepIndex == -1) {
      return false;
    }

    return stepIndex <= currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final parsedStatus = requestStatusFromString(request.status);
    final progress = _progressValue(parsedStatus);

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: cs.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingSmall,
                AppSizes.paddingSmall,
                AppSizes.paddingMedium,
                AppSizes.paddingSmall,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_forward,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          request.displayNumber,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall / 2),
                        Text(
                          request.displayTitle,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  RequestStatusBadge(status: request.status),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  children: [
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).round()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l10n.progress,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingSmall),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                                  cs.surfaceVariant.withOpacity(0.45),
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.timeline,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          ..._timelineStatuses().map(
                            (step) {
                              final completed = _isCompletedStep(
                                parsedStatus,
                                step,
                              );

                              final isLast = step == _timelineStatuses().last;

                              return _TimelineRow(
                                status: step,
                                completed: completed,
                                isLast: isLast,
                                date: completed ? request.date : '',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.details,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _DetailRow(
                            icon: Icons.confirmation_number_outlined,
                            label: l10n.requestNumber,
                            value: request.displayNumber,
                          ),
                          const SizedBox(height: AppSizes.paddingSmall),
                          _DetailRow(
                            icon: Icons.description_outlined,
                            label: l10n.descriptionLabel,
                            value: request.description.trim().isEmpty
                                ? l10n.notAvailable
                                : request.description,
                          ),
                          const SizedBox(height: AppSizes.paddingSmall),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: l10n.locationLabel,
                            value: request.addressText.trim().isEmpty
                                ? l10n.notAvailable
                                : request.addressText,
                          ),
                          const SizedBox(height: AppSizes.paddingSmall),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: l10n.submissionDate,
                            value: request.date.trim().isEmpty
                                ? l10n.notAvailable
                                : request.date,
                          ),
                        ],
                      ),
                    ),
                    if (parsedStatus == CitizenRequestStatus.waitingPayment) ...[
                      const SizedBox(height: AppSizes.paddingSmall),
                      _PaymentCard(
                        onPayPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                    const SizedBox(height: AppSizes.paddingMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: cs.outline.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final CitizenRequestStatus status;
  final bool completed;
  final bool isLast;
  final String date;

  const _TimelineRow({
    required this.status,
    required this.completed,
    required this.isLast,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final activeColor = cs.primary;
    final inactiveColor = cs.surfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: AppSizes.iconSmall,
              height: AppSizes.iconSmall,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? activeColor : inactiveColor,
              ),
              child: completed
                  ? Icon(
                      Icons.check,
                      color: cs.onPrimary,
                      size: AppSizes.iconSmall * 0.70,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: AppSizes.paddingLarge,
                color: completed ? activeColor : inactiveColor,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: AppSizes.paddingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  requestStatusLabel(l10n, status),
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: completed ? cs.onSurface : cs.onSurfaceVariant,
                    fontWeight: completed ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                if (date.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSizes.paddingSmall / 2),
                  Text(
                    date,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: cs.onSurfaceVariant,
          size: AppSizes.iconSmall,
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall / 2),
              Text(
                value,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final VoidCallback onPayPressed;

  const _PaymentCard({
    required this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: Colors.orange.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.amountDue,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall / 2),
          Text(
            l10n.notAvailable,
            textAlign: TextAlign.right,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          PrimaryButton(
            label: l10n.payNow,
            onPressed: onPayPressed,
          ),
        ],
      ),
    );
  }
}