import 'dart:async';
import 'dart:io';

import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StaffCertificateScreen extends StatefulWidget {
  final int processInstanceKey;
  final String taskName;

  const StaffCertificateScreen({
    super.key,
    required this.processInstanceKey,
    required this.taskName,
  });

  @override
  State<StaffCertificateScreen> createState() => _StaffCertificateScreenState();
}

class _StaffCertificateScreenState extends State<StaffCertificateScreen> {
  static const int _maxAttempts = 20;
  static const Duration _pollInterval = Duration(seconds: 2);

  final StaffTaskApiService _api = StaffTaskApiService();

  bool _polling = true;
  bool _downloading = false;
  String? _error;
  Map<String, dynamic>? _certificate;
  int _attempts = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
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
          _error = 'Certificate not ready yet. Please check again later.';
        });
      }
    }
  }

  Future<void> _download() async {
    final certId = _certificate?['id'];
    if (certId == null) return;

    setState(() => _downloading = true);
    try {
      final id = certId is int ? certId : int.parse(certId.toString());
      final bytes = await _api.downloadCertificateBytes(id);
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          _certificate?['fileName']?.toString() ?? 'certificate_$id.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Certificate saved: $fileName',
        type: AppToastType.success,
      );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Certificate'),
        leading: BackButton(
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _polling
              ? _buildPolling(theme, colors)
              : _error != null
                  ? _buildError(theme, colors)
                  : _buildCertificate(theme, colors),
        ),
      ),
    );
  }

  Widget _buildPolling(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Generating certificate…',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: colors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Unknown error',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Back to Tasks'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificate(ThemeData theme, ColorScheme colors) {
    final cert = _certificate!;
    final fileName = cert['fileName']?.toString() ?? 'certificate.pdf';
    final createdAt = cert['createdAt']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 56,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(height: 12),
              Text(
                'Certificate Ready',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.onPrimaryContainer,
                ),
              ),
              if (createdAt.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  createdAt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                      'PDF Document',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _downloading ? null : _download,
          icon: _downloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined),
          label: Text(_downloading ? 'Downloading…' : 'Download PDF'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, true),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
