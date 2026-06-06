import 'dart:async';
import 'dart:io';

import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffCertificateScreen extends StatefulWidget {
  final int processInstanceKey;
  final String taskName;
  final Map<String, dynamic> taskVariables;

  const StaffCertificateScreen({
    super.key,
    required this.processInstanceKey,
    required this.taskName,
    this.taskVariables = const {},
  });

  @override
  State<StaffCertificateScreen> createState() => _StaffCertificateScreenState();
}

class _StaffCertificateScreenState extends State<StaffCertificateScreen> {
  static const int _maxAttempts = 20;
  static const Duration _pollInterval = Duration(seconds: 2);
  static const String _prefKeyPrefix = 'cert_file_';

  final StaffTaskApiService _api = StaffTaskApiService();

  bool _polling = true;
  bool _downloading = false;
  String? _error;
  Map<String, dynamic>? _certificate;
  int _attempts = 0;
  Timer? _timer;
  String? _savedFilePath;

  String get _prefKey => '$_prefKeyPrefix${widget.processInstanceKey}';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_prefKey);
    if (savedPath != null && File(savedPath).existsSync()) {
      try {
        final cert = await _api.getCertificateByProcessInstanceKey(
          widget.processInstanceKey,
        );
        if (!mounted) return;
        setState(() {
          _certificate = cert;
          _savedFilePath = savedPath;
          _polling = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _savedFilePath = savedPath;
          _polling = false;
          _certificate = {'fileName': savedPath.split('/').last};
        });
      }
      return;
    }
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _polling = true;
      _error = null;
      _attempts = 0;
    });
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<void> _poll() async {
    if (!mounted) return;
    _attempts++;
    try {
      final cert = await _api.getCertificateByProcessInstanceKey(
        widget.processInstanceKey,
      );
      _timer?.cancel();
      if (!mounted) return;
      setState(() {
        _certificate = cert;
        _polling = false;
      });
    } catch (_) {
      if (_attempts >= _maxAttempts) {
        _timer?.cancel();
        if (!mounted) return;
        setState(() {
          _polling = false;
          _error = 'timeout';
        });
      }
    }
  }

  Future<Directory> _getSaveDir() async {
    if (Platform.isAndroid) {
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    }
    return getApplicationDocumentsDirectory();
  }

  Future<String> _resolveFilePath(int certId) async {
    final dir = await _getSaveDir();
    final fileName =
        _certificate?['fileName']?.toString() ?? 'certificate_$certId.pdf';
    return '${dir.path}/$fileName';
  }

  Future<void> _persistFilePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, path);
  }

  Future<void> _downloadAndOpen() async {
    final certId = _certificate?['id'];
    if (certId == null) return;

    setState(() => _downloading = true);
    try {
      final id = certId is int ? certId : int.parse(certId.toString());
      final bytes = await _api.downloadCertificateBytes(id);
      final filePath = await _resolveFilePath(id);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await _persistFilePath(filePath);

      if (!mounted) return;
      setState(() => _savedFilePath = filePath);

      await OpenFilex.open(filePath);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: errorMessage(e),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _openSaved() async {
    final path = _savedFilePath;
    if (path == null) return;
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done && mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.show(
        context,
        message: '${l10n.couldNotOpenFile}: ${result.message}',
        type: AppToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.certificate),
        leading: BackButton(
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _polling
              ? _buildPolling(theme, colors, l10n)
              : _error != null
                  ? _buildError(theme, colors, l10n)
                  : _buildCertificate(theme, colors, l10n),
        ),
      ),
    );
  }

  Widget _buildPolling(ThemeData theme, ColorScheme colors, AppLocalizations l10n) {
    return SizedBox(
      height: 340,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              l10n.generatingCertificate,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.certificateTakingTime,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colors, AppLocalizations l10n) {
    return SizedBox(
      height: 340,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.certificateNotReady,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _startPolling,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(l10n.retry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.backToTasks),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificate(ThemeData theme, ColorScheme colors, AppLocalizations l10n) {
    final cert = _certificate!;
    final fileName = cert['fileName']?.toString() ?? 'certificate.pdf';
    final certId = cert['id']?.toString() ?? '';
    final createdAt = cert['createdAt']?.toString() ?? '';
    final isSigned = cert['isSigned'] == true;
    final request = cert['request'] as Map? ?? {};
    final trackingNumber = request['trackingNumber']?.toString() ?? '';
    final requestTitle = request['title']?.toString() ??
        request['titleAr']?.toString() ??
        widget.taskName;
    final alreadySaved = _savedFilePath != null;

    // Merge request data + task variables for display
    final displayVars = <String, String>{};
    for (final entry in widget.taskVariables.entries) {
      final key = entry.key;
      final val = entry.value;
      if (val == null || val.toString().trim().isEmpty) continue;
      // Skip known attachment/binary keys
      if (key.toLowerCase().contains('url') ||
          key.toLowerCase().contains('attachment') ||
          key.toLowerCase().contains('file')) continue;
      displayVars[_labelFromKey(key)] = val.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Certificate card ─────────────────────────────────────────────────
        _CertificatePreviewCard(
          theme: theme,
          colors: colors,
          taskName: requestTitle,
          certId: certId,
          createdAt: createdAt,
          isSigned: isSigned,
          trackingNumber: trackingNumber,
          variables: displayVars,
        ),
        const SizedBox(height: 16),

        // ── PDF file card ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withOpacity(0.14)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: colors.onErrorContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      alreadySaved
                          ? l10n.certificateReady
                          : l10n.pdfDocument,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: alreadySaved ? colors.primary : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (alreadySaved)
                Icon(Icons.check_circle, color: colors.primary, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Action buttons ────────────────────────────────────────────────────
        if (alreadySaved) ...[
          FilledButton.icon(
            onPressed: _openSaved,
            icon: const Icon(Icons.open_in_new_outlined),
            label: Text(l10n.openPdf),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _downloading ? null : _downloadAndOpen,
            icon: _downloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: Text(_downloading ? l10n.loading : l10n.downloadAgain),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ] else ...[
          FilledButton.icon(
            onPressed: _downloading ? null : _downloadAndOpen,
            icon: _downloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: Text(_downloading ? l10n.loading : l10n.downloadAndOpen),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, true),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(l10n.done),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _labelFromKey(String key) {
    final s = key
        .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')
        .replaceAll('_', ' ')
        .trim();
    if (s.isEmpty) return key;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

// ─── Certificate preview card ─────────────────────────────────────────────────

class _CertificatePreviewCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colors;
  final String taskName;
  final String certId;
  final String createdAt;
  final bool isSigned;
  final String trackingNumber;
  final Map<String, String> variables;

  const _CertificatePreviewCard({
    required this.theme,
    required this.colors,
    required this.taskName,
    required this.certId,
    required this.createdAt,
    required this.isSigned,
    required this.trackingNumber,
    required this.variables,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with primary gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_outlined,
                        color: colors.onPrimary.withOpacity(0.85), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Municipality Certificate',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimary.withOpacity(0.85),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Icon(Icons.verified, color: colors.onPrimary, size: 44),
                const SizedBox(height: 8),
                Text(
                  taskName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isSigned) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 14, color: colors.onPrimary),
                        const SizedBox(width: 5),
                        Text(
                          'Officially Signed',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Decorative dashed separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: CustomPaint(
              size: const Size(double.infinity, 12),
              painter: _DashedLinePainter(color: colors.primary.withOpacity(0.3)),
            ),
          ),

          // Certificate body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meta row
                Row(
                  children: [
                    if (certId.isNotEmpty) ...[
                      _MetaBadge(
                        icon: Icons.numbers,
                        label: '#$certId',
                        colors: colors,
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (trackingNumber.isNotEmpty) ...[
                      _MetaBadge(
                        icon: Icons.confirmation_number_outlined,
                        label: trackingNumber,
                        colors: colors,
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (createdAt.isNotEmpty)
                      _MetaBadge(
                        icon: Icons.calendar_today_outlined,
                        label: createdAt.length > 10
                            ? createdAt.substring(0, 10)
                            : createdAt,
                        colors: colors,
                        theme: theme,
                      ),
                  ],
                ),

                if (variables.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Request Details',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...variables.entries.map(
                    (e) => _DetailRow(
                      label: e.key,
                      value: e.value,
                      theme: theme,
                      colors: colors,
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Footer notice
                Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: colors.primary.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'This document is digitally generated by the municipal system.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colors;
  final ThemeData theme;

  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double x = 0;
    const dashWidth = 6.0;
    const dashGap = 4.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
