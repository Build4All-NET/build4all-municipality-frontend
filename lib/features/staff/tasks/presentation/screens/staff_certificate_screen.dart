import 'dart:async';
import 'dart:io';

import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Check SharedPreferences for a previously saved file path
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_prefKey);
    if (savedPath != null && File(savedPath).existsSync()) {
      // File still exists on device — try to fetch metadata, then show without polling
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
        // Metadata fetch failed, but file is local — show minimal info
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
          _error = 'Certificate not ready yet.\nTap Retry to check again.';
        });
      }
    }
  }

  Future<String> _resolveFilePath(int certId) async {
    final dir = await getApplicationDocumentsDirectory();
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
      AppToast.show(
        context,
        message: 'Could not open file: ${result.message}',
        type: AppToastType.error,
      );
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
          FilledButton.icon(
            onPressed: _startPolling,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Retry'),
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
    final alreadySaved = _savedFilePath != null;

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
        if (alreadySaved) ...[
          FilledButton.icon(
            onPressed: _openSaved,
            icon: const Icon(Icons.open_in_new_outlined),
            label: const Text('Open PDF'),
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
            label: Text(_downloading ? 'Downloading…' : 'Download Again'),
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
            label: Text(_downloading ? 'Downloading…' : 'Download & Open'),
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
          child: const Text('Done'),
        ),
      ],
    );
  }
}
