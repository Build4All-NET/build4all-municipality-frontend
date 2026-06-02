import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Bloc.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Event.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_State.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestDetailPage extends StatelessWidget {
  final RequestModel request;

  const RequestDetailPage({
    super.key,
    required this.request,
  });

  String _safe(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty || clean.toLowerCase() == 'null' ? '—' : clean;
  }

  String _formatDate(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty || clean.toLowerCase() == 'null') return '—';
    return clean.replaceFirst('T', ' ').split('.').first;
  }

  String _formatCoordinate(double value) {
    if (value == 0) return '—';
    return value.toStringAsFixed(6);
  }

  String _localizedStatus(AppLocalizations l10n, String? status) {
    final clean = status?.trim().toUpperCase() ?? '';

    switch (clean) {
      case 'SUBMITTED':
        return l10n.statusSubmitted;
      case 'PENDING':
        return l10n.statusPending;
      case 'UNDER_REVIEW':
        return l10n.statusUnderReview;
      case 'DOCUMENTS_MISSING':
        return l10n.statusDocumentsMissing;
      case 'IN_PROGRESS':
        return l10n.statusInProgress;
      case 'APPROVED':
        return l10n.statusApproved;
      case 'REJECTED':
        return l10n.statusRejected;
      case 'COMPLETED':
        return l10n.statusCompleted;
      case 'CANCELLED':
        return l10n.statusCancelled;
      default:
        return _safe(status).replaceAll('_', ' ');
    }
  }

  Color _statusColor(BuildContext context, String? status) {
    final colors = Theme.of(context).colorScheme;
    final clean = status?.trim().toUpperCase() ?? '';

    switch (clean) {
      case 'APPROVED':
      case 'COMPLETED':
        return colors.primary;
      case 'REJECTED':
      case 'CANCELLED':
      case 'DOCUMENTS_MISSING':
        return colors.error;
      case 'IN_PROGRESS':
      case 'UNDER_REVIEW':
        return colors.tertiary;
      case 'SUBMITTED':
      case 'PENDING':
      default:
        return colors.secondary;
    }
  }

  IconData _statusIcon(String? status) {
    final clean = status?.trim().toUpperCase() ?? '';

    switch (clean) {
      case 'APPROVED':
        return Icons.verified_outlined;
      case 'REJECTED':
        return Icons.cancel_outlined;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'CANCELLED':
        return Icons.block_outlined;
      case 'IN_PROGRESS':
      case 'UNDER_REVIEW':
        return Icons.timelapse_outlined;
      case 'DOCUMENTS_MISSING':
        return Icons.folder_off_outlined;
      case 'SUBMITTED':
      case 'PENDING':
      default:
        return Icons.pending_actions_outlined;
    }
  }

  bool _isClosedStatus(String? status) {
    final clean = status?.trim().toUpperCase() ?? '';
    return clean == 'COMPLETED' ||
        clean == 'REJECTED' ||
        clean == 'CANCELLED';
  }

  void _changeStatus(
    BuildContext context,
    AppLocalizations l10n,
    String status,
  ) {
    final id = request.id;

    if (id == null) {
      AppToast.show(
        context,
        message: l10n.invalidRequestId,
        type: AppToastType.error,
      );
      return;
    }

    context.read<RequestBloc>().add(
          UpdateRequestStatusRequested(
            id: id,
            status: status,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _statusColor(context, request.status);
    final statusText = _localizedStatus(l10n, request.status);
    final isClosed = _isClosedStatus(request.status);

    return BlocConsumer<RequestBloc, RequestState>(
      listenWhen: (previous, current) {
        return previous.success != current.success ||
            previous.error != current.error;
      },
      listener: (context, state) {
        final success = state.success.trim();
        final error = state.error.trim();

        if (success.isNotEmpty) {
          AppToast.show(
            context,
            message: success,
            type: AppToastType.success,
          );
          Navigator.pop(context, true);
        }

        if (error.isNotEmpty) {
          AppToast.show(
            context,
            message: error,
            type: AppToastType.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          appBar: AppBar(
            title: Text(
              l10n.requestDetails,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth < 360 ? 12.0 : 16.0;

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(
                          title: _safe(request.title),
                          trackingNumber: _safe(request.trackingNumber),
                          status: statusText,
                          statusColor: statusColor,
                          statusIcon: _statusIcon(request.status),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: l10n.requestInformation,
                          icon: Icons.info_outline,
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.location_city_outlined,
                                label: l10n.municipality,
                                value: Env.appName,
                              ),
                              _DetailRow(
                                icon: Icons.miscellaneous_services_outlined,
                                label: l10n.service,
                                value: _safe(request.serviceName),
                              ),
                              _DetailRow(
                                icon: Icons.person_outline,
                                label: l10n.citizen,
                                value: _safe(request.citizenName),
                              ),
                              _DetailRow(
                                icon: Icons.confirmation_number_outlined,
                                label: l10n.tracking,
                                value: _safe(request.trackingNumber),
                              ),
                              _DetailRow(
                                icon: Icons.account_tree_outlined,
                                label: 'Process Key',
                                value: request.processInstanceKey == null
                                    ? '—'
                                    : request.processInstanceKey.toString(),
                              ),
                              _DetailRow(
                                icon: Icons.category_outlined,
                                label: l10n.category,
                                value: _safe(request.category),
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: l10n.location,
                          icon: Icons.location_on_outlined,
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.home_outlined,
                                label: l10n.address,
                                value: _safe(request.addressText),
                              ),
                              _DetailRow(
                                icon: Icons.map_outlined,
                                label: l10n.latitude,
                                value: _formatCoordinate(request.geoLat),
                              ),
                              _DetailRow(
                                icon: Icons.map_outlined,
                                label: l10n.longitude,
                                value: _formatCoordinate(request.geoLng),
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: l10n.timeline,
                          icon: Icons.timeline_outlined,
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.calendar_today_outlined,
                                label: l10n.created,
                                value: _formatDate(request.createdAt),
                              ),
                              _DetailRow(
                                icon: Icons.update_outlined,
                                label: l10n.updated,
                                value: _formatDate(request.updatedAt),
                              ),
                              _DetailRow(
                                icon: Icons.event_available_outlined,
                                label: l10n.closed,
                                value: _formatDate(request.closedAt),
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: l10n.description,
                          icon: Icons.notes_outlined,
                          child: Text(
                            _safe(request.description),
                            softWrap: true,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!isClosed)
                          _ActionsCard(
                            isLoading: state.updating,
                            onReject: () {
                              if (state.updating) return;
                              _changeStatus(context, l10n, 'REJECTED');
                            },
                            onApprove: () {
                              if (state.updating) return;
                              _changeStatus(context, l10n, 'APPROVED');
                            },
                            onComplete: () {
                              if (state.updating) return;
                              _changeStatus(context, l10n, 'COMPLETED');
                            },
                          )
                        else
                          _ClosedStatusCard(status: statusText),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final String title;
  final String trackingNumber;
  final String status;
  final Color statusColor;
  final IconData statusIcon;

  const _HeaderCard({
    required this.title,
    required this.trackingNumber,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.assignment_outlined,
                color: colors.onPrimary,
                size: compact ? 26 : 30,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 18 : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trackingNumber,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onPrimary.withOpacity(0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _StatusPill(
                label: status,
                icon: statusIcon,
                foregroundColor: colors.onPrimary,
                backgroundColor: colors.onPrimary.withOpacity(0.14),
                borderColor: colors.onPrimary.withOpacity(0.22),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 330;

              if (compact) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            softWrap: true,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      softWrap: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.7,
            color: colors.outlineVariant.withOpacity(0.55),
          ),
      ],
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final VoidCallback onComplete;

  const _ActionsCard({
    required this.isLoading,
    required this.onReject,
    required this.onApprove,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.55),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackButtons = constraints.maxWidth < 340;

          final rejectButton = PrimaryButton(
            label: isLoading ? l10n.loading : l10n.reject,
            backgroundColor: colors.error,
            textColor: colors.onError,
            isLoading: isLoading,
            onPressed: onReject,
          );

          final approveButton = PrimaryButton(
            label: isLoading ? l10n.loading : l10n.approve,
            backgroundColor: colors.primary,
            textColor: colors.onPrimary,
            isLoading: isLoading,
            onPressed: onApprove,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.actions,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (stackButtons) ...[rejectButton, const SizedBox(height: 10), approveButton]
              else
                Row(
                  children: [
                    Expanded(child: rejectButton),
                    const SizedBox(width: 10),
                    Expanded(child: approveButton),
                  ],
                ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: isLoading ? l10n.loading : l10n.complete,
                backgroundColor: colors.primary,
                textColor: colors.onPrimary,
                isLoading: isLoading,
                onPressed: onComplete,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClosedStatusCard extends StatelessWidget {
  final String status;

  const _ClosedStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.requestClosedMessage(status),
              softWrap: true,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _StatusPill({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: foregroundColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
