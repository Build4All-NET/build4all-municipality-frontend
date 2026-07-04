import 'package:flutter/material.dart';
import 'package:baladiyati/features/citizen/requests/domain/entities/request_entity.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'requests_screen.dart' show StatusBadgeWidget;

class RequestDetailsScreen extends StatelessWidget {
  final RequestEntity request;
  const RequestDetailsScreen({super.key, required this.request});

  static const List<_StepDef> _steps = [
    _StepDef('SUBMITTED'),
    _StepDef('UNDER_REVIEW'),
    _StepDef('IN_PROGRESS'),
    _StepDef('APPROVED'),
    _StepDef('TAX_PAID'),
    _StepDef('COMPLETED'),
  ];

  static int _statusOrder(String s) {
    switch (s) {
      case 'DRAFT': return 0;
      case 'SUBMITTED': return 1;
      case 'UNDER_REVIEW': return 2;
      case 'DOCUMENTS_MISSING': return 2;
      case 'IN_PROGRESS': return 3;
      case 'APPROVED': return 4;
      case 'TAX_PAID': return 5;
      case 'TAX_REJECTED': return 5;
      case 'COMPLETED': return 6;
      case 'REJECTED': return 6;
      case 'CANCELLED': return 6;
      default: return 1;
    }
  }

  bool get _isNegativeEnd =>
      request.status == 'REJECTED' ||
      request.status == 'CANCELLED' ||
      request.status == 'TAX_REJECTED';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentOrder = _statusOrder(request.status);
    final completedSteps = _steps.where((s) => _statusOrder(s.status) <= currentOrder).length;
    final progress = completedSteps / _steps.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.requestDetails),
            if (request.trackingNumber.isNotEmpty)
              Text(
                '#${request.trackingNumber}',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(0.65)),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusBadgeWidget(status: request.status),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status banners
            if (request.status == 'DOCUMENTS_MISSING')
              _Banner(
                icon: Icons.folder_off_outlined,
                title: loc.statusDocumentsMissing,
                message: loc.errorGeneric,
                color: colors.error,
              ),
            if (request.status == 'REJECTED')
              _Banner(
                icon: Icons.cancel_outlined,
                title: loc.rejected,
                message: loc.errorGeneric,
                color: colors.error,
              ),
            if (request.status == 'CANCELLED')
              _Banner(
                icon: Icons.block_outlined,
                title: loc.statusCancelled,
                message: loc.errorGeneric,
                color: colors.outline,
              ),
            if (request.status == 'COMPLETED')
              _Banner(
                icon: Icons.check_circle_outline,
                title: loc.completed,
                message: loc.requestSubmittedTitle,
                color: colors.primary,
              ),

            // Progress card
            _Card(
              theme: theme,
              colors: colors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.outline),
                      ),
                      Text(
                        loc.progress,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: colors.outline.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isNegativeEnd ? colors.error : colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Timeline card
            _Card(
              theme: theme,
              colors: colors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.timeline,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_steps.length, (i) {
                    final step = _steps[i];
                    final stepOrder = _statusOrder(step.status);
                    final isDone = stepOrder <= currentOrder && !_isNegativeEnd;
                    final isCurrent = step.status == request.status;
                    final isLast = i == _steps.length - 1;
                    final dotColor = _isNegativeEnd && isCurrent
                        ? colors.error
                        : isDone
                            ? colors.primary
                            : colors.outline.withOpacity(0.3);

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                              child: isDone && !isCurrent
                                  ? Icon(Icons.check, size: 8, color: colors.onPrimary)
                                  : null,
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 44,
                                color: isDone ? colors.primary.withOpacity(0.4) : colors.outline.withOpacity(0.15),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  StatusBadgeWidget.label(AppLocalizations.of(context)!, step.status),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                                    color: isDone ? colors.onSurface : colors.outline,
                                  ),
                                ),
                                if (isCurrent)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: StatusBadgeWidget(status: request.status),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (_isNegativeEnd) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: colors.error),
                          child: Icon(Icons.close, size: 8, color: colors.onError),
                        ),
                        const SizedBox(width: 12),
                        StatusBadgeWidget(status: request.status),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Details card
            _Card(
              theme: theme,
              colors: colors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.details, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (request.title.isNotEmpty)
                    _DetailRow(icon: Icons.title_outlined, label: loc.titleLabel, value: request.title, theme: theme, colors: colors),
                  if (request.description.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(icon: Icons.description_outlined, label: loc.descriptionLabel, value: request.description, theme: theme, colors: colors),
                  ],
                  if (request.serviceName != null && request.serviceName!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(icon: Icons.description_outlined, label: loc.services, value: switch (request.serviceName!) {
                      'Building Permit' => loc.serviceBuildingPermit,
                      'Larger Building Permit' => loc.serviceLargerBuildingPermit,
                      'Housing Permit' => loc.serviceHousingPermit,
                      'External Works' => loc.serviceExternalWorks,
                      'Illegal Construction' => loc.serviceIllegalConstruction,
                      'Valuation Certificate' => loc.serviceValuationCertificate,
                      'Clearance Certificate' => loc.serviceClearanceCertificate,
                      'Tent Permit' => loc.serviceTentPermit,
                      'Property Access' => loc.servicePropertyAccess,
                      'Residence Certificate' => loc.serviceResidenceCertificate,
                      'Contents Certificate' => loc.serviceContentsCertificate,
                      'Work Certificate' => loc.serviceWorkCertificate,
                      'Lease Registration' => loc.serviceLeaseRegistration,
                      _ => request.serviceName!,
                    }, theme: theme, colors: colors),
                  ],
                  if (request.addressText != null && request.addressText!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(icon: Icons.location_on_outlined, label: loc.address, value: request.addressText!, theme: theme, colors: colors),
                  ],
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: loc.submissionDate,
                    value: _formatDate(request.createdAt),
                    theme: theme,
                    colors: colors,
                  ),
                  if (request.updatedAt != null) ...[
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.update_outlined,
                      label: loc.updatedAt,
                      value: _formatDate(request.updatedAt),
                      theme: theme,
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _StepDef {
  final String status;
  const _StepDef(this.status);
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _Banner({required this.icon, required this.title, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final ThemeData theme;
  final ColorScheme colors;

  const _Card({required this.child, required this.theme, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: colors.shadow.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  const _DetailRow({required this.icon, required this.label, required this.value, required this.theme, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colors.outline),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colors.outline)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
