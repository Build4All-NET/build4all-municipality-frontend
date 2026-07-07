import 'dart:io';
import 'dart:typed_data';

import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Bloc.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Event.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_State.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class RequestDetailPage extends StatefulWidget {
  final RequestModel request;

  const RequestDetailPage({
    super.key,
    required this.request,
  });

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  late String? _status;
  final TextEditingController _rejectionController = TextEditingController();
  bool _isStaffOrOwner = true;

  @override
  void initState() {
    super.initState();
    _status = widget.request.status;
    _rejectionController.addListener(_onRejectionTextChanged);
    _loadRole();
  }

  @override
  void dispose() {
    _rejectionController.removeListener(_onRejectionTextChanged);
    _rejectionController.dispose();
    super.dispose();
  }

  void _onRejectionTextChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadRole() async {
    final role = await SessionRoleStore().getRole();
    final allowed = role == 'STAFF' || role == 'OWNER';
    if (mounted && allowed != _isStaffOrOwner) {
      setState(() => _isStaffOrOwner = allowed);
    }
  }

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
      case 'TAX_PAID':
        return l10n.statusTaxPaid;
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
      case 'TAX_PAID':
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
      case 'TAX_PAID':
        return Icons.payments_outlined;
      case 'SUBMITTED':
      case 'PENDING':
      default:
        return Icons.pending_actions_outlined;
    }
  }

  bool _isTerminalStatus(String? status) {
    final clean = status?.trim().toUpperCase() ?? '';
    return clean == 'COMPLETED' ||
        clean == 'REJECTED' ||
        clean == 'CANCELLED' ||
        clean == 'TAX_PAID';
  }

  // Returns which action buttons to show based on current status
  _AllowedActions _allowedActions(String? status) {
    final s = status?.trim().toUpperCase() ?? '';
    if (_isTerminalStatus(status)) return const _AllowedActions();
    if (s == 'APPROVED' || s == 'IN_PROGRESS') {
      return _AllowedActions(
        showComplete: true,
        showReject: true,
        showPay: s == 'APPROVED' && _isStaffOrOwner,
      );
    }
    // SUBMITTED, PENDING, UNDER_REVIEW, DOCUMENTS_MISSING, etc.
    return const _AllowedActions(showApprove: true, showReject: true);
  }

  String _successMessage(AppLocalizations l10n, String status) {
    switch (status.trim().toUpperCase()) {
      case 'APPROVED':
        return l10n.requestApprovedSuccess;
      case 'REJECTED':
        return l10n.requestRejectedSuccess;
      case 'COMPLETED':
        return l10n.requestCompletedSuccess;
      default:
        return l10n.updated;
    }
  }

  Future<void> _changeStatus(
    BuildContext context,
    AppLocalizations l10n,
    String status,
  ) async {
    final id = widget.request.id;

    if (id == null) {
      AppToast.show(
        context,
        message: l10n.invalidRequestId,
        type: AppToastType.error,
      );
      return;
    }

    String? message;
    if (status == 'REJECTED') {
      message = _rejectionController.text.trim();
      if (message.isEmpty) {
        AppToast.show(
          context,
          message: l10n.rejectionReasonRequired,
          type: AppToastType.error,
        );
        return;
      }
    }

    final confirmTitle = status == 'REJECTED' ? l10n.reject : l10n.approve;
    final confirmMessage = status == 'REJECTED'
        ? l10n.confirmRejectRequest
        : (status == 'APPROVED' ? l10n.confirmApproveRequest : null);

    if (confirmMessage != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(confirmTitle),
            content: Text(confirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(confirmTitle),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;
    }

    if (!context.mounted) return;

    context.read<RequestBloc>().add(
          UpdateRequestStatusRequested(
            id: id,
            status: status,
            message: message,
          ),
        );
  }

  Future<void> _payRequest(BuildContext context, AppLocalizations l10n) async {
    final id = widget.request.id;

    if (id == null) {
      AppToast.show(
        context,
        message: l10n.invalidRequestId,
        type: AppToastType.error,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.payRequest),
          content: Text(l10n.confirmPayRequest),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.pay),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    context.read<RequestBloc>().add(MarkRequestPaidRequested(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _statusColor(context, _status);
    final statusText = _localizedStatus(l10n, _status);
    final isClosed = _isTerminalStatus(_status);
    final actions = _allowedActions(_status);

    return BlocConsumer<RequestBloc, RequestState>(
      listenWhen: (previous, current) {
        return previous.success != current.success ||
            previous.error != current.error ||
            previous.paidRequestId != current.paidRequestId ||
            previous.payError != current.payError;
      },
      listener: (context, state) {
        final success = state.success.trim();
        final error = state.error.trim();

        if (success.isNotEmpty) {
          AppToast.show(
            context,
            message: _successMessage(l10n, success),
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

        if (state.paidRequestId != null &&
            state.paidRequestId == widget.request.id) {
          setState(() => _status = 'TAX_PAID');
          AppToast.show(
            context,
            message: l10n.requestPaidSuccess,
            type: AppToastType.success,
          );
        }

        final payError = state.payError.trim();
        if (payError.isNotEmpty) {
          AppToast.show(
            context,
            message: payError,
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
                          title: _safe(widget.request.title),
                          trackingNumber: _safe(widget.request.trackingNumber),
                          status: statusText,
                          statusColor: statusColor,
                          statusIcon: _statusIcon(_status),
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
                                value: switch (widget.request.serviceName) {
                                  'Building Permit' => l10n.serviceBuildingPermit,
                                  'Larger Building Permit' => l10n.serviceLargerBuildingPermit,
                                  'Housing Permit' => l10n.serviceHousingPermit,
                                  'External Works' => l10n.serviceExternalWorks,
                                  'Illegal Construction' => l10n.serviceIllegalConstruction,
                                  'Valuation Certificate' => l10n.serviceValuationCertificate,
                                  'Clearance Certificate' => l10n.serviceClearanceCertificate,
                                  'Tent Permit' => l10n.serviceTentPermit,
                                  'Property Access' => l10n.servicePropertyAccess,
                                  'Residence Certificate' => l10n.serviceResidenceCertificate,
                                  'Contents Certificate' => l10n.serviceContentsCertificate,
                                  'Work Certificate' => l10n.serviceWorkCertificate,
                                  'Lease Registration' => l10n.serviceLeaseRegistration,
                                  _ => _safe(widget.request.serviceName),
                                },
                              ),
                              _DetailRow(
                                icon: Icons.person_outline,
                                label: l10n.citizen,
                                value: _safe(widget.request.citizenName),
                              ),
                              _DetailRow(
                                icon: Icons.confirmation_number_outlined,
                                label: l10n.tracking,
                                value: _safe(widget.request.trackingNumber),
                              ),
                              _DetailRow(
                                icon: Icons.account_tree_outlined,
                                label: 'Process Key',
                                value: widget.request.processInstanceKey == null
                                    ? '—'
                                    : widget.request.processInstanceKey.toString(),
                              ),
                              _DetailRow(
                                icon: Icons.category_outlined,
                                label: l10n.category,
                                value: _safe(widget.request.category),
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
                                value: _safe(widget.request.addressText),
                              ),
                              _DetailRow(
                                icon: Icons.map_outlined,
                                label: l10n.latitude,
                                value: _formatCoordinate(widget.request.geoLat),
                              ),
                              _DetailRow(
                                icon: Icons.map_outlined,
                                label: l10n.longitude,
                                value: _formatCoordinate(widget.request.geoLng),
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
                                value: _formatDate(widget.request.createdAt),
                              ),
                              _DetailRow(
                                icon: Icons.update_outlined,
                                label: l10n.updated,
                                value: _formatDate(widget.request.updatedAt),
                              ),
                              _DetailRow(
                                icon: Icons.event_available_outlined,
                                label: l10n.closed,
                                value: _formatDate(widget.request.closedAt),
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
                            _safe(widget.request.description),
                            softWrap: true,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (widget.request.attachments.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _AttachmentsSection(
                            attachments: widget.request.attachments,
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (isClosed)
                          _status?.trim().toUpperCase() == 'TAX_PAID'
                              ? _PaidBadgeCard(label: l10n.alreadyPaid)
                              : _ClosedStatusCard(status: statusText)
                        else
                          _ActionsCard(
                            isLoading: state.updating,
                            isPayLoading: state.payUpdating,
                            actions: actions,
                            rejectionController: _rejectionController,
                            rejectDisabled:
                                _rejectionController.text.trim().isEmpty,
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
                            onPay: () {
                              if (state.payUpdating) return;
                              _payRequest(context, l10n);
                            },
                          ),
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

class _AllowedActions {
  final bool showApprove;
  final bool showReject;
  final bool showComplete;
  final bool showPay;

  const _AllowedActions({
    this.showApprove = false,
    this.showReject = false,
    this.showComplete = false,
    this.showPay = false,
  });
}

class _ActionsCard extends StatelessWidget {
  final bool isLoading;
  final bool isPayLoading;
  final _AllowedActions actions;
  final TextEditingController rejectionController;
  final bool rejectDisabled;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final VoidCallback onComplete;
  final VoidCallback onPay;

  const _ActionsCard({
    required this.isLoading,
    required this.isPayLoading,
    required this.actions,
    required this.rejectionController,
    required this.rejectDisabled,
    required this.onReject,
    required this.onApprove,
    required this.onComplete,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final rejectButton = actions.showReject
        ? PrimaryButton(
            label: isLoading ? l10n.loading : l10n.reject,
            backgroundColor: colors.error,
            textColor: colors.onError,
            isLoading: isLoading,
            enabled: !rejectDisabled,
            onPressed: onReject,
          )
        : null;

    final approveButton = actions.showApprove
        ? PrimaryButton(
            label: isLoading ? l10n.loading : l10n.approve,
            backgroundColor: colors.primary,
            textColor: colors.onPrimary,
            isLoading: isLoading,
            onPressed: onApprove,
          )
        : null;

    final completeButton = actions.showComplete
        ? PrimaryButton(
            label: isLoading ? l10n.loading : l10n.complete,
            backgroundColor: colors.primary,
            textColor: colors.onPrimary,
            isLoading: isLoading,
            onPressed: onComplete,
          )
        : null;

    final payButton = actions.showPay
        ? PrimaryButton(
            label: isPayLoading ? l10n.loading : l10n.pay,
            backgroundColor: colors.primary,
            textColor: colors.onPrimary,
            isLoading: isPayLoading,
            onPressed: onPay,
          )
        : null;

    final mainRow = [
      if (rejectButton != null) rejectButton,
      if (approveButton != null) approveButton,
    ];

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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.staffActions,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (actions.showReject) ...[
                TextField(
                  controller: rejectionController,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: l10n.rejectionReason,
                    hintText: l10n.enterRejectionReason,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (mainRow.length == 2)
                stackButtons
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          mainRow[0],
                          const SizedBox(height: 10),
                          mainRow[1],
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: mainRow[0]),
                          const SizedBox(width: 10),
                          Expanded(child: mainRow[1]),
                        ],
                      )
              else if (mainRow.length == 1)
                mainRow[0],
              if (completeButton != null) ...[
                if (mainRow.isNotEmpty) const SizedBox(height: 10),
                completeButton,
              ],
              if (payButton != null) ...[
                if (mainRow.isNotEmpty || completeButton != null)
                  const SizedBox(height: 10),
                payButton,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PaidBadgeCard extends StatelessWidget {
  final String label;

  const _PaidBadgeCard({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              softWrap: true,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Attachments section ──────────────────────────────────────────────────────

class _AttachmentsSection extends StatelessWidget {
  final List<Attachment> attachments;

  const _AttachmentsSection({required this.attachments});

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
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Icon(Icons.attach_file, color: colors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.requiredAttachments,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${attachments.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...attachments.map(
            (a) => _AttachmentCard(attachment: a),
          ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatefulWidget {
  final Attachment attachment;

  const _AttachmentCard({required this.attachment});

  @override
  State<_AttachmentCard> createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<_AttachmentCard> {
  static const _kImageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp'};

  bool _downloading = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  String get _ext =>
      widget.attachment.fileName.split('.').last.toLowerCase();

  bool get _isImage => _kImageExts.contains(_ext);

  String _resolveUrl(String url) {
    if (url.startsWith('http')) return url;
    final base = Env.overrideBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return '$base$url';
  }

  String _cacheKey() {
    final name = widget.attachment.fileName;
    if (name.isNotEmpty) return name;
    return 'attachment_${widget.attachment.fileUrl.hashCode.abs()}';
  }

  Future<Directory> _cacheDir() async {
    try {
      return (await getExternalStorageDirectory())!;
    } catch (_) {
      return getApplicationDocumentsDirectory();
    }
  }

  Future<void> _checkCache() async {
    try {
      final dir = await _cacheDir();
      final path = '${dir.path}/${_cacheKey()}';
      if (File(path).existsSync()) {
        if (mounted) setState(() => _localPath = path);
      }
    } catch (_) {}
  }

  Future<void> _openOrDownload(BuildContext context) async {
    if (_localPath != null && File(_localPath!).existsSync()) {
      await OpenFilex.open(_localPath!);
      return;
    }
    await _download(context);
  }

  Future<void> _download(BuildContext context) async {
    setState(() => _downloading = true);
    try {
      final fullUrl = _resolveUrl(widget.attachment.fileUrl);
      late Uint8List bytes;
      try {
        final response = await DioClient.muni.get<List<int>>(
          fullUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = Uint8List.fromList(response.data!);
      } on DioException catch (_) {
        final response = await DioClient.muni.get<List<int>>(
          widget.attachment.fileUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = Uint8List.fromList(response.data!);
      }

      final dir = await _cacheDir();
      final path = '${dir.path}/${_cacheKey()}';
      await File(path).writeAsBytes(bytes);

      if (mounted) setState(() => _localPath = path);
      if (!context.mounted) return;
      await OpenFilex.open(path);
    } catch (_) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        message: AppLocalizations.of(context)!.couldNotOpenFile,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  IconData get _fileIcon {
    if (_isImage) return Icons.image_outlined;
    if (_ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(_ext)) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isCached = _localPath != null && File(_localPath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCached
              ? colors.primary.withOpacity(0.25)
              : colors.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCached && _isImage)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(_localPath!),
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading:
                Icon(_fileIcon, color: colors.primary, size: 22),
            title: Text(
              widget.attachment.fileName.isNotEmpty
                  ? widget.attachment.fileName
                  : widget.attachment.fileUrl.split('/').last,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: isCached
                ? Text(
                    l10n.openPdf,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: colors.primary),
                  )
                : null,
            trailing: _downloading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      isCached ? Icons.open_in_new : Icons.download_outlined,
                      color: colors.primary,
                      size: 20,
                    ),
                    tooltip: isCached ? l10n.openPdf : l10n.downloadAndOpen,
                    onPressed: () => _openOrDownload(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          ),
        ],
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
