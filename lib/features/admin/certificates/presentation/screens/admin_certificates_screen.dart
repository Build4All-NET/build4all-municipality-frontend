import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/admin/certificates/data/models/certificate_model.dart';
import 'package:baladiyati/features/admin/certificates/presentation/cubit/admin_certificate_cubit.dart';
import 'package:baladiyati/features/admin/certificates/presentation/cubit/admin_certificate_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _CertFilter { all, signed, unsigned }

class AdminCertificatesScreen extends StatefulWidget {
  const AdminCertificatesScreen({super.key});

  @override
  State<AdminCertificatesScreen> createState() =>
      _AdminCertificatesScreenState();
}

class _AdminCertificatesScreenState extends State<AdminCertificatesScreen> {
  _CertFilter _filter = _CertFilter.all;
  bool _newestFirst = true;

  List<CertificateModel> _apply(List<CertificateModel> list) {
    var result = list.where((c) {
      return switch (_filter) {
        _CertFilter.all => true,
        _CertFilter.signed => c.isSigned,
        _CertFilter.unsigned => !c.isSigned,
      };
    }).toList();

    result.sort((a, b) {
      final da = a.createdAtDate ?? DateTime(0);
      final db = b.createdAtDate ?? DateTime(0);
      return _newestFirst ? db.compareTo(da) : da.compareTo(db);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocConsumer<AdminCertificateCubit, AdminCertificateState>(
      listener: (context, state) {
        if (state.success == 'SIGNED') {
          AppToast.show(
            context,
            message: loc.certificateSigned,
            type: AppToastType.success,
          );
        } else if (state.success == 'UNSIGNED') {
          AppToast.show(
            context,
            message: loc.certificateUnsigned,
            type: AppToastType.success,
          );
        }
        if (state.error != null) {
          AppToast.show(
            context,
            message: state.error!,
            type: AppToastType.error,
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final cubit = context.read<AdminCertificateCubit>();
        final filtered = _apply(state.certificates);

        final signedCount = state.certificates.where((c) => c.isSigned).length;
        final unsignedCount =
            state.certificates.where((c) => !c.isSigned).length;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(loc.certificate),
            actions: [
              if (state.actionLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (!state.loading && state.certificates.isNotEmpty)
                IconButton(
                  tooltip:
                      _newestFirst ? loc.oldestFirst : loc.newestFirst,
                  icon: Icon(
                    _newestFirst
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                  ),
                  onPressed: () =>
                      setState(() => _newestFirst = !_newestFirst),
                ),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed:
                    state.loading ? null : cubit.loadCertificates,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: cubit.loadCertificates,
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.certificates.isEmpty
                    ? _EmptyView(loc: loc, theme: theme, colors: colors)
                    : CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: _Header(
                                total: state.certificates.length,
                                signedCount: signedCount,
                                unsignedCount: unsignedCount,
                                theme: theme,
                                colors: colors,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: _FilterChips(
                                selected: _filter,
                                total: state.certificates.length,
                                signedCount: signedCount,
                                unsignedCount: unsignedCount,
                                onChanged: (f) =>
                                    setState(() => _filter = f),
                                loc: loc,
                                theme: theme,
                                colors: colors,
                              ),
                            ),
                          ),
                          if (filtered.isEmpty)
                            SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_list_off,
                                      size: 48,
                                      color: colors.outline,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _filter == _CertFilter.signed
                                          ? loc.certFilterSigned
                                          : loc.certFilterUnsigned,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: colors.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No certificates in this category.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: colors.outline),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 96),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _CertificateCard(
                                    certificate: filtered[index],
                                    loc: loc,
                                    theme: theme,
                                    colors: colors,
                                    actionLoading: state.actionLoading,
                                    cubit: cubit,
                                  ),
                                  childCount: filtered.length,
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int total;
  final int signedCount;
  final int unsignedCount;
  final ThemeData theme;
  final ColorScheme colors;

  const _Header({
    required this.total,
    required this.signedCount,
    required this.unsignedCount,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.verified_outlined, color: colors.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.manageCertificates,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$signedCount signed · $unsignedCount pending',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$total',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final _CertFilter selected;
  final int total;
  final int signedCount;
  final int unsignedCount;
  final void Function(_CertFilter) onChanged;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colors;

  const _FilterChips({
    required this.selected,
    required this.total,
    required this.signedCount,
    required this.unsignedCount,
    required this.onChanged,
    required this.loc,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: loc.filterAll,
            count: total,
            selected: selected == _CertFilter.all,
            onTap: () => onChanged(_CertFilter.all),
            theme: theme,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: loc.certFilterSigned,
            count: signedCount,
            selected: selected == _CertFilter.signed,
            onTap: () => onChanged(_CertFilter.signed),
            theme: theme,
            colors: colors,
            selectedColor: colors.tertiary,
            selectedOnColor: colors.onTertiary,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: loc.certFilterUnsigned,
            count: unsignedCount,
            selected: selected == _CertFilter.unsigned,
            onTap: () => onChanged(_CertFilter.unsigned),
            theme: theme,
            colors: colors,
            selectedColor: colors.errorContainer,
            selectedOnColor: colors.onErrorContainer,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme colors;
  final Color? selectedColor;
  final Color? selectedOnColor;

  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.theme,
    required this.colors,
    this.selectedColor,
    this.selectedOnColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (selectedColor ?? colors.primary)
        : colors.surfaceVariant.withOpacity(0.6);
    final fg = selected
        ? (selectedOnColor ?? colors.onPrimary)
        : colors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : colors.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? fg.withOpacity(0.18)
                    : colors.outline.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Certificate card ─────────────────────────────────────────────────────────

class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colors;
  final bool actionLoading;
  final AdminCertificateCubit cubit;

  const _CertificateCard({
    required this.certificate,
    required this.loc,
    required this.theme,
    required this.colors,
    required this.actionLoading,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final signed = certificate.isSigned;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: signed
              ? colors.primary.withOpacity(0.22)
              : colors.outline.withOpacity(0.14),
          width: signed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: signed
                  ? colors.primary.withOpacity(0.06)
                  : colors.surfaceVariant.withOpacity(0.35),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: signed
                        ? colors.primary.withOpacity(0.12)
                        : colors.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: signed ? colors.primary : colors.outline,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    certificate.fileName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  signed: signed,
                  loc: loc,
                  theme: theme,
                  colors: colors,
                ),
              ],
            ),
          ),

          // ── Info rows ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                if (certificate.requestTitle != '-')
                  _InfoRow(
                    icon: Icons.miscellaneous_services_outlined,
                    label: loc.service,
                    value: certificate.requestTitle,
                    theme: theme,
                    colors: colors,
                  ),
                if (certificate.citizenName != '-')
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: loc.citizen,
                    value: certificate.citizenName,
                    theme: theme,
                    colors: colors,
                  ),
                if (certificate.trackingNumber != '-')
                  _InfoRow(
                    icon: Icons.tag_outlined,
                    label: loc.tracking,
                    value: certificate.trackingNumber,
                    theme: theme,
                    colors: colors,
                  ),
                if (certificate.requestId != null)
                  _InfoRow(
                    icon: Icons.numbers_outlined,
                    label: loc.requestIdLabel,
                    value: '#${certificate.requestId}',
                    theme: theme,
                    colors: colors,
                  ),
                if (certificate.requestStatus != '-')
                  _InfoRow(
                    icon: Icons.info_outline,
                    label: loc.status,
                    value: _humaniseStatus(loc, certificate.requestStatus),
                    theme: theme,
                    colors: colors,
                    valueColor:
                        _statusColor(certificate.requestStatus, colors),
                  ),
                if (certificate.formattedDate != '-')
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: loc.dateLabel,
                    value: certificate.formattedDate,
                    theme: theme,
                    colors: colors,
                  ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: actionLoading
                        ? null
                        : () {
                            final reqId = certificate.requestId;
                            if (reqId == null) return;
                            if (signed) {
                              cubit.unsignCertificate(reqId);
                            } else {
                              cubit.signCertificate(reqId);
                            }
                          },
                    icon: Icon(
                      signed
                          ? Icons.remove_moderator_outlined
                          : Icons.verified_user_outlined,
                      size: 16,
                    ),
                    label: Text(
                      signed ? loc.unsignCertificate : loc.signCertificate,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          signed ? colors.error : colors.primary,
                      side: BorderSide(
                        color: signed
                            ? colors.error.withOpacity(0.5)
                            : colors.primary.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: actionLoading
                        ? null
                        : () => cubit.downloadAndOpenCertificate(
                              certificate.id,
                              certificate.fileName,
                            ),
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: Text(
                      loc.downloadAndOpen,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _humaniseStatus(AppLocalizations loc, String status) {
    final clean = status.trim().toUpperCase();
    return switch (clean) {
      'SUBMITTED' => loc.statusSubmitted,
      'PENDING' => loc.statusPending,
      'UNDER_REVIEW' => loc.statusUnderReview,
      'DOCUMENTS_MISSING' => loc.statusDocumentsMissing,
      'IN_PROGRESS' => loc.statusInProgress,
      'APPROVED' => loc.statusApproved,
      'REJECTED' => loc.statusRejected,
      'COMPLETED' => loc.statusCompleted,
      'CANCELLED' => loc.statusCancelled,
      _ => status.replaceAll('_', ' '),
    };
  }

  Color _statusColor(String status, ColorScheme colors) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return colors.tertiary;
      case 'APPROVED':
      case 'IN_PROGRESS':
        return colors.primary;
      case 'REJECTED':
      case 'CANCELLED':
        return colors.error;
      default:
        return colors.onSurfaceVariant;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool signed;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colors;

  const _StatusBadge({
    required this.signed,
    required this.loc,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: signed
            ? colors.primary.withOpacity(0.12)
            : colors.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            signed ? Icons.verified_outlined : Icons.pending_outlined,
            size: 13,
            color: signed ? colors.primary : colors.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            signed ? loc.verified : loc.notVerified,
            style: theme.textTheme.labelSmall?.copyWith(
              color: signed ? colors.primary : colors.onErrorContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: colors.outline),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? colors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty view ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colors;

  const _EmptyView({
    required this.loc,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        Icon(Icons.verified_outlined, size: 72, color: colors.outline),
        const SizedBox(height: 16),
        Text(
          loc.noCertificates,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          loc.noCertificatesHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: colors.outline),
        ),
      ],
    );
  }
}
