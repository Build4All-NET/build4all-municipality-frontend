import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/admin/certificates/data/models/certificate_model.dart';
import 'package:baladiyati/features/admin/certificates/presentation/cubit/admin_certificate_cubit.dart';
import 'package:baladiyati/features/admin/certificates/presentation/cubit/admin_certificate_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminCertificatesScreen extends StatelessWidget {
  const AdminCertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(loc.certificate),
            actions: [
              if (state.actionLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: context.read<AdminCertificateCubit>().loadCertificates,
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.certificates.isEmpty
                    ? _EmptyView(loc: loc, theme: theme, colors: colors)
                    : _CertificateList(
                        certificates: state.certificates,
                        loc: loc,
                        theme: theme,
                        colors: colors,
                        actionLoading: state.actionLoading,
                      ),
          ),
        );
      },
    );
  }
}

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
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          loc.noCertificatesHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.outline),
        ),
      ],
    );
  }
}

class _CertificateList extends StatelessWidget {
  final List<CertificateModel> certificates;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colors;
  final bool actionLoading;

  const _CertificateList({
    required this.certificates,
    required this.loc,
    required this.theme,
    required this.colors,
    required this.actionLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
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
                      loc.manageCertificates,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${certificates.length} ${loc.certificate}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...certificates.map(
          (cert) => _CertificateCard(
            certificate: cert,
            loc: loc,
            theme: theme,
            colors: colors,
            actionLoading: actionLoading,
          ),
        ),
      ],
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colors;
  final bool actionLoading;

  const _CertificateCard({
    required this.certificate,
    required this.loc,
    required this.theme,
    required this.colors,
    required this.actionLoading,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCertificateCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: colors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  certificate.fileName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: certificate.isSigned
                      ? colors.primary.withOpacity(0.12)
                      : colors.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  certificate.isSigned ? loc.verified : loc.notVerified,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: certificate.isSigned ? colors.primary : colors.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (certificate.requestTitle != '-') ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: loc.service,
              value: certificate.requestTitle,
              theme: theme,
              colors: colors,
            ),
          ],
          if (certificate.trackingNumber != '-') ...[
            const SizedBox(height: 4),
            _InfoRow(
              label: loc.tracking,
              value: certificate.trackingNumber,
              theme: theme,
              colors: colors,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: actionLoading
                      ? null
                      : () {
                          final reqId = certificate.requestId;
                          if (reqId == null) return;
                          if (certificate.isSigned) {
                            cubit.unsignCertificate(reqId);
                          } else {
                            cubit.signCertificate(reqId);
                          }
                        },
                  icon: Icon(
                    certificate.isSigned
                        ? Icons.remove_moderator_outlined
                        : Icons.verified_user_outlined,
                    size: 16,
                  ),
                  label: Text(
                    certificate.isSigned ? loc.unsignCertificate : loc.signCertificate,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: certificate.isSigned ? colors.error : colors.primary,
                    side: BorderSide(
                      color: certificate.isSigned
                          ? colors.error.withOpacity(0.5)
                          : colors.primary.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
