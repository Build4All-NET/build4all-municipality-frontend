import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:baladiyati/features/staff/tasks/presentation/screens/staff_certificate_screen.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class StaffTaskFormScreen extends StatefulWidget {
  final StaffTaskModel task;
  final StaffTaskApiService? apiService;

  const StaffTaskFormScreen({
    super.key,
    required this.task,
    this.apiService,
  });

  @override
  State<StaffTaskFormScreen> createState() => _StaffTaskFormScreenState();
}

// ─── Normalised field definition ─────────────────────────────────────────────

class _FieldDef {
  final String key;
  final String type;
  final String label;
  final bool required;
  final dynamic defaultValue;
  final List<_FieldOption> options;
  final bool readOnly;
  final num? min;
  final num? max;
  final String? placeholder;

  const _FieldDef({
    required this.key,
    required this.type,
    required this.label,
    this.required = false,
    this.defaultValue,
    this.options = const [],
    this.readOnly = false,
    this.min,
    this.max,
    this.placeholder,
  });
}

class _FieldOption {
  final String value;
  final String label;

  const _FieldOption({required this.value, required this.label});
}

// ─── Screen state ────────────────────────────────────────────────────────────

class _StaffTaskFormScreenState extends State<StaffTaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _loadingDetail = true;
  bool _loadingForm = true;
  bool _submitting = false;

  Map<String, dynamic> _taskDetail = {};
  List<_FieldDef> _fields = [];

  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, bool> _checkboxValues = {};
  final Map<String, String?> _selectValues = {};
  final Map<String, DateTime?> _dateValues = {};

  late final StaffTaskApiService _api;

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? StaffTaskApiService();
    _init();
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    await Future.wait([_loadDetail(), _loadForm()]);
  }

  Future<void> _loadDetail() async {
    final taskId = widget.task.id;
    if (taskId == null) {
      setState(() => _loadingDetail = false);
      return;
    }
    try {
      final detail = await _api.getTaskById(taskId);
      if (!mounted) return;
      setState(() {
        _taskDetail = detail;
        _loadingDetail = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _loadForm() async {
    final taskId = widget.task.id;
    if (taskId == null) {
      setState(() => _loadingForm = false);
      return;
    }
    try {
      final formData = await _api.getTaskForm(taskId);
      if (!mounted) return;
      final fields = _parseFields(formData);
      _initFieldState(fields);
      setState(() {
        _fields = fields;
        _loadingForm = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loadingForm = false);
      if (e.response?.statusCode == 404) return; // task has no form — proceed without one
      AppToast.show(context, message: errorMessage(e), type: AppToastType.error);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingForm = false);
      AppToast.show(context, message: errorMessage(e), type: AppToastType.error);
    }
  }

  // ── Field parsing ────────────────────────────────────────────────────────

  List<_FieldDef> _parseComponents(List components) {
    return components
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((c) =>
            (c['key']?.toString() ?? '').isNotEmpty &&
            (c['type']?.toString() ?? '').isNotEmpty)
        .map(_fieldFromCamunda)
        .toList();
  }

  List<_FieldDef> _parseFields(Map<String, dynamic> data) {
    // 1. Camunda API format: { "schema": "JSON string", "formId": "..." }
    final rawSchema = data['schema'];
    if (rawSchema != null) {
      Map<String, dynamic> schema;
      if (rawSchema is Map) {
        schema = Map<String, dynamic>.from(rawSchema);
      } else if (rawSchema is String && rawSchema.trim().isNotEmpty) {
        final decoded = jsonDecode(rawSchema);
        schema = decoded is Map ? Map<String, dynamic>.from(decoded) : {};
      } else {
        schema = {};
      }
      final components = schema['components'];
      if (components is List && components.isNotEmpty) {
        return _parseComponents(components);
      }
    }

    // 2. Direct form file format: { "components": [...], "type": "default" }
    final rawComponents = data['components'];
    if (rawComponents is List && rawComponents.isNotEmpty) {
      return _parseComponents(rawComponents);
    }

    // 3. Simple fields array format: { "fields": [...] }
    final rawFields = data['fields'];
    if (rawFields is List) {
      return rawFields
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((f) =>
              ((f['name'] ?? f['key'])?.toString() ?? '').isNotEmpty &&
              (f['type']?.toString() ?? '').isNotEmpty)
          .map(_fieldFromSimple)
          .toList();
    }

    return [];
  }

  _FieldDef _fieldFromCamunda(Map<String, dynamic> c) {
    final validate = c['validate'];
    final isRequired =
        (validate is Map && validate['required'] == true) ||
            c['required'] == true;
    final num? min = validate is Map
        ? (validate['min'] is num ? validate['min'] as num : null)
        : null;
    final num? max = validate is Map
        ? (validate['max'] is num ? validate['max'] as num : null)
        : null;

    final rawValues = c['values'];
    final options = rawValues is List
        ? rawValues
            .whereType<Map>()
            .map((v) => Map<String, dynamic>.from(v))
            .map((v) => _FieldOption(
                  value: v['value']?.toString() ?? '',
                  label: v['label']?.toString() ??
                      v['name']?.toString() ??
                      v['value']?.toString() ??
                      '',
                ))
            .toList()
        : <_FieldOption>[];

    return _FieldDef(
      key: c['key']?.toString() ?? '',
      type: c['type']?.toString().toLowerCase() ?? 'text',
      label: c['label']?.toString() ?? c['key']?.toString() ?? '',
      required: isRequired,
      defaultValue: c['defaultValue'],
      options: options,
      readOnly: c['disabled'] == true || c['readonly'] == true,
      min: min,
      max: max,
      placeholder: c['placeholder']?.toString(),
    );
  }

  _FieldDef _fieldFromSimple(Map<String, dynamic> f) {
    final key = (f['name'] ?? f['key'])?.toString() ?? '';
    final type = f['type']?.toString().toLowerCase() ?? 'text';
    final rawOptions = f['options'];
    final options = rawOptions is List
        ? rawOptions.map((o) {
            if (o is Map) {
              return _FieldOption(
                value: o['value']?.toString() ?? o.toString(),
                label: o['label']?.toString() ?? o['value']?.toString() ?? o.toString(),
              );
            }
            return _FieldOption(value: o.toString(), label: o.toString());
          }).toList()
        : <_FieldOption>[];

    return _FieldDef(
      key: key,
      type: type,
      label: f['label']?.toString() ?? key,
      required: f['required'] == true,
      defaultValue: f['default'] ?? f['defaultValue'],
      options: options,
      readOnly: f['readOnly'] == true || f['disabled'] == true,
      min: f['min'] is num ? f['min'] as num : null,
      max: f['max'] is num ? f['max'] as num : null,
      placeholder: f['placeholder']?.toString(),
    );
  }

  void _initFieldState(List<_FieldDef> fields) {
    for (final field in fields) {
      final def = field.defaultValue;
      switch (field.type) {
        case 'checkbox':
          _checkboxValues[field.key] = def == true;
        case 'select':
        case 'radio':
        case 'dropdown':
        case 'checklist':
          _selectValues[field.key] = def?.toString();
        case 'date':
          if (def is String && def.isNotEmpty) {
            _dateValues[field.key] = DateTime.tryParse(def);
          } else {
            _dateValues[field.key] = null;
          }
        default:
          _textControllers[field.key] =
              TextEditingController(text: def?.toString() ?? '');
      }
    }
  }

  // ── Submit

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final taskId = widget.task.id;

    if (taskId == null) {
      AppToast.show(context,
          message: l10n.noFormFound, type: AppToastType.error);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final variables = <String, dynamic>{};

    for (final field in _fields) {
      if (field.readOnly) continue;
      switch (field.type) {
        case 'number':
          final raw = _textControllers[field.key]?.text.trim() ?? '';
          if (raw.isEmpty) {
            variables[field.key] = null;
          } else {
            variables[field.key] =
                int.tryParse(raw) ?? double.tryParse(raw) ?? raw;
          }
        case 'checkbox':
          variables[field.key] = _checkboxValues[field.key] ?? false;
        case 'select':
        case 'radio':
        case 'dropdown':
        case 'checklist':
          variables[field.key] = _selectValues[field.key];
        case 'date':
          final d = _dateValues[field.key];
          variables[field.key] =
              d != null ? d.toIso8601String().split('T').first : null;
        default:
          variables[field.key] =
              _textControllers[field.key]?.text.trim() ?? '';
      }
    }

    setState(() => _submitting = true);

    try {
      await _api.completeTask(taskId: taskId, variables: variables);
      if (!mounted) return;
      AppToast.show(
        context,
        message: l10n.formSubmittedSuccessfully,
        type: AppToastType.success,
      );
      final pik = widget.task.certificateLookupKey;
      if (pik != null) {
        final allVars = <String, dynamic>{
          ...widget.task.variables,
          if (_taskDetail['variables'] is Map)
            ...Map<String, dynamic>.from(_taskDetail['variables'] as Map),
          ...variables,
        };
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StaffCertificateScreen(
              processInstanceKey: pik,
              taskName: widget.task.name,
              taskVariables: allVars,
            ),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
          context, message: errorMessage(e), type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openCertificate() {
    final pik = widget.task.certificateLookupKey;
    if (pik == null) return;
    final allVars = <String, dynamic>{
      ...widget.task.variables,
      if (_taskDetail['variables'] is Map)
        ...Map<String, dynamic>.from(_taskDetail['variables'] as Map),
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffCertificateScreen(
          processInstanceKey: pik,
          taskName: widget.task.name,
          taskVariables: allVars,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLoading = _loadingDetail || _loadingForm;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.task.displayName.isNotEmpty ? widget.task.displayName : l10n.taskForm,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      l10n.loadingForm,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TaskInfoCard(
                        task: widget.task,
                        detail: _taskDetail,
                      ),
                      const SizedBox(height: 16),
                      if (widget.task.isCompleted)
                        _CompletedBanner(
                          onViewCertificate: widget.task.certificateLookupKey != null
                              ? _openCertificate
                              : null,
                        )
                      else ...[
                        if (_fields.isEmpty)
                          _NoFormCard(
                            onComplete: _submit,
                            submitting: _submitting,
                          )
                        else ...[
                          _FormCard(
                            fields: _fields,
                            textControllers: _textControllers,
                            checkboxValues: _checkboxValues,
                            selectValues: _selectValues,
                            dateValues: _dateValues,
                            onCheckboxChanged: (key, val) => setState(
                                () => _checkboxValues[key] = val),
                            onSelectChanged: (key, val) =>
                                setState(() => _selectValues[key] = val),
                            onDateChanged: (key, val) =>
                                setState(() => _dateValues[key] = val),
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: l10n.submitTaskForm,
                            isLoading: _submitting,
                            onPressed: _submit,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── Task info header card ────────────────────────────────────────────────────

class _TaskInfoCard extends StatelessWidget {
  final StaffTaskModel task;
  final Map<String, dynamic> detail;

  const _TaskInfoCard({required this.task, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final stateUpper = task.state.toUpperCase();
    final bool isDone =
        stateUpper == 'COMPLETED' || stateUpper == 'DONE';
    final Color stateBg = isDone
        ? colors.surfaceVariant
        : colors.primaryContainer;
    final Color stateFg = isDone
        ? colors.onSurfaceVariant
        : colors.onPrimaryContainer;

    // Merge variables from model + detail response
    final variables = <String, dynamic>{
      ...task.variables,
      if (detail['variables'] is Map)
        ...Map<String, dynamic>.from(detail['variables'] as Map)
      else if (detail['variables'] is List)
        ...() {
          final m = <String, dynamic>{};
          for (final item in detail['variables'] as List) {
            if (item is Map) {
              final n = item['name']?.toString() ?? item['key']?.toString();
              if (n != null) m[n] = item['value'];
            }
          }
          return m;
        }(),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: stateBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isDone ? l10n.completed : switch (task.state.toUpperCase()) {
                    'CREATED' => l10n.statusPending,
                    'ASSIGNED' => l10n.statusAssigned,
                    '' => l10n.statusPending,
                    _ => task.state,
                  },
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: stateFg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (task.creationDate.isNotEmpty)
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: task.creationDate,
                  colors: colors,
                  theme: theme,
                ),
              ...task.departmentLabels.map((d) => _InfoChip(
                    icon: Icons.account_balance_outlined,
                    label: d,
                    colors: colors,
                    theme: theme,
                  )),
            ],
          ),
          if (variables.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              l10n.requestInformation,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...variables.entries
                .where((e) =>
                    e.value != null &&
                    e.value.toString().trim().isNotEmpty)
                .map((e) {
                  final urls = _parseAttachmentUrls(e.key, e.value);
                  if (urls.isNotEmpty) {
                    return _AttachmentsVarRow(urls: urls);
                  }
                  return _VarRow(label: e.key, value: e.value.toString());
                }),
          ],
        ],
      ),
    );
  }
}

// ─── Attachment URL helpers ───────────────────────────────────────────────────

const _kAttachmentKeys = {
  'attachmentUrls',
  'attachementUrls',
  'attachments',
  'fileUrls',
  'files',
};

List<String> _parseAttachmentUrls(String key, dynamic value) {
  List<String> candidates = [];

  if (value is List) {
    candidates = value
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
  } else if (value is String) {
    final trimmed = value.trim();
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          candidates = decoded
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }
    if (candidates.isEmpty && trimmed.isNotEmpty) {
      candidates = [trimmed];
    }
  }

  if (candidates.isEmpty) return [];

  // If the key is a known attachment key, accept as-is.
  if (_kAttachmentKeys.contains(key)) return candidates;

  // Otherwise only treat as attachments if ALL values look like file paths/URLs.
  final looksLikeUrl = candidates.every(
    (s) => s.startsWith('http') || s.startsWith('/uploads') || s.startsWith('/files') || s.startsWith('/api/files'),
  );
  return looksLikeUrl ? candidates : [];
}

String _resolveFileUrl(String url) {
  if (url.startsWith('http')) return url;
  final base = Env.overrideBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  return '$base$url';
}

String _fileNameFromUrl(String url) {
  return url.split('/').last.split('?').first;
}

// ─── Attachments variable row ─────────────────────────────────────────────────

class _AttachmentsVarRow extends StatelessWidget {
  final List<String> urls;

  const _AttachmentsVarRow({required this.urls});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, size: 14, color: colors.primary),
              const SizedBox(width: 4),
              Text(
                l10n.requiredAttachments,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...urls.map((url) => _FileDownloadCard(url: url)),
        ],
      ),
    );
  }
}

// ─── Individual file download card ───────────────────────────────────────────

class _FileDownloadCard extends StatefulWidget {
  final String url;

  const _FileDownloadCard({required this.url});

  @override
  State<_FileDownloadCard> createState() => _FileDownloadCardState();
}

class _FileDownloadCardState extends State<_FileDownloadCard> {
  bool _downloading = false;
  String? _localPath;

  static const _kImageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp'};

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  String _cacheFileName(String url) {
    final name = _fileNameFromUrl(url);
    if (name.isNotEmpty && name.contains('.')) return name;
    return 'attachment_${url.hashCode.abs()}';
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
      final path = '${dir.path}/${_cacheFileName(widget.url)}';
      if (File(path).existsSync()) {
        if (mounted) setState(() => _localPath = path);
      }
    } catch (_) {}
  }

  IconData _iconForFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (_kImageExts.contains(ext)) return Icons.image_outlined;
    if (['doc', 'docx'].contains(ext)) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }

  bool _isImage(String name) =>
      _kImageExts.contains(name.split('.').last.toLowerCase());

  Future<void> _openOrDownload(BuildContext context) async {
    // If already cached, just open it
    if (_localPath != null && File(_localPath!).existsSync()) {
      await OpenFilex.open(_localPath!);
      return;
    }
    await _download(context);
  }

  Future<void> _download(BuildContext context) async {
    setState(() => _downloading = true);

    try {
      final fullUrl = _resolveFileUrl(widget.url);
      final fileName = _cacheFileName(widget.url);

      Uint8List bytes;
      try {
        final response = await DioClient.muni.get<List<int>>(
          fullUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = Uint8List.fromList(response.data!);
      } on DioException catch (_) {
        final response = await DioClient.muni.get<List<int>>(
          widget.url,
          options: Options(responseType: ResponseType.bytes),
        );
        bytes = Uint8List.fromList(response.data!);
      }

      final dir = await _cacheDir();
      final path = '${dir.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(bytes);

      if (mounted) setState(() => _localPath = path);

      if (!context.mounted) return;
      await OpenFilex.open(path);
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final fileName = _fileNameFromUrl(widget.url);
    final displayName = fileName.isNotEmpty ? fileName : widget.url;
    final isCached = _localPath != null && File(_localPath!).existsSync();
    final isImg = _isImage(displayName);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCached
              ? colors.primary.withOpacity(0.25)
              : colors.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCached && isImg)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.file(
                File(_localPath!),
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Icon(_iconForFile(displayName), color: colors.primary, size: 22),
            title: Text(
              displayName,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
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

// ─── Info chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colors;
  final ThemeData theme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VarRow extends StatelessWidget {
  final String label;
  final String value;

  const _VarRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
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

// ─── Completed banner ─────────────────────────────────────────────────────────

class _CompletedBanner extends StatelessWidget {
  final VoidCallback? onViewCertificate;

  const _CompletedBanner({this.onViewCertificate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.taskAlreadyCompleted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (onViewCertificate != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onViewCertificate,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(l10n.viewCertificate),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── No form card (complete with no variables) ────────────────────────────────

class _NoFormCard extends StatelessWidget {
  final VoidCallback onComplete;
  final bool submitting;

  const _NoFormCard(
      {required this.onComplete, required this.submitting});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: colors.onSurfaceVariant, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.noInputRequired,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: l10n.submitTaskForm,
            isLoading: submitting,
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}

// ─── Dynamic form card ────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<_FieldDef> fields;
  final Map<String, TextEditingController> textControllers;
  final Map<String, bool> checkboxValues;
  final Map<String, String?> selectValues;
  final Map<String, DateTime?> dateValues;
  final void Function(String key, bool val) onCheckboxChanged;
  final void Function(String key, String? val) onSelectChanged;
  final void Function(String key, DateTime? val) onDateChanged;

  const _FormCard({
    required this.fields,
    required this.textControllers,
    required this.checkboxValues,
    required this.selectValues,
    required this.dateValues,
    required this.onCheckboxChanged,
    required this.onSelectChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.fillRequiredFields,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DynamicField(
                field: field,
                textController: textControllers[field.key],
                checkboxValue: checkboxValues[field.key] ?? false,
                selectValue: selectValues[field.key],
                dateValue: dateValues[field.key],
                onCheckboxChanged: (val) =>
                    onCheckboxChanged(field.key, val),
                onSelectChanged: (val) =>
                    onSelectChanged(field.key, val),
                onDateChanged: (val) => onDateChanged(field.key, val),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dynamic field widget ─────────────────────────────────────────────────────

class _DynamicField extends StatelessWidget {
  final _FieldDef field;
  final TextEditingController? textController;
  final bool checkboxValue;
  final String? selectValue;
  final DateTime? dateValue;
  final void Function(bool) onCheckboxChanged;
  final void Function(String?) onSelectChanged;
  final void Function(DateTime?) onDateChanged;

  const _DynamicField({
    required this.field,
    this.textController,
    required this.checkboxValue,
    required this.selectValue,
    required this.dateValue,
    required this.onCheckboxChanged,
    required this.onSelectChanged,
    required this.onDateChanged,
  });

  String? _validateText(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (field.required && (value == null || value.trim().isEmpty)) {
      return l10n.requiredField;
    }
    return null;
  }

  String? _validateNumber(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final v = value?.trim() ?? '';
    if (field.required && v.isEmpty) return l10n.requiredField;
    if (v.isNotEmpty) {
      final num? n = num.tryParse(v);
      if (n == null) return l10n.invalidNumber;
      if (field.min != null && n < field.min!) {
        return 'Minimum value is ${field.min}';
      }
      if (field.max != null && n > field.max!) {
        return 'Maximum value is ${field.max}';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final type = field.type;

    // ── Read-only / display
    if (field.readOnly || type == 'readonly' || type == 'display') {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              textController?.text ?? field.defaultValue?.toString() ?? '-',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    // ── Checkbox
    if (type == 'checkbox') {
      return Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: CheckboxListTile(
          value: checkboxValue,
          title: Text(
            field.label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          onChanged: (val) => onCheckboxChanged(val ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12),
        ),
      );
    }

    // ── Radio buttons
    if (type == 'radio') {
      return FormField<String>(
        initialValue: selectValue,
        validator: field.required
            ? (v) {
                if (v == null || v.isEmpty) return l10n.requiredField;
                return null;
              }
            : null,
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${field.label}${field.required ? ' *' : ''}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: state.hasError
                      ? colors.error
                      : colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.hasError
                        ? colors.error
                        : colors.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: field.options.map((opt) {
                    return RadioListTile<String>(
                      value: opt.value,
                      groupValue: state.value,
                      title: Text(opt.label),
                      onChanged: (val) {
                        state.didChange(val);
                        onSelectChanged(val);
                      },
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, top: 4),
                  child: Text(
                    state.errorText ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colors.error),
                  ),
                ),
            ],
          );
        },
      );
    }

    // ── Select / dropdown
    if (type == 'select' || type == 'dropdown' || type == 'checklist') {
      return DropdownButtonFormField<String>(
        value: selectValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.placeholder,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: field.required
            ? (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              }
            : null,
        items: field.options
            .map((opt) => DropdownMenuItem<String>(
                  value: opt.value,
                  child: Text(opt.label),
                ))
            .toList(),
        onChanged: onSelectChanged,
      );
    }

    // ── Date picker
    if (type == 'date') {
      return FormField<DateTime>(
        initialValue: dateValue,
        validator: field.required
            ? (v) {
                if (v == null) return l10n.requiredField;
                return null;
              }
            : null,
        builder: (state) {
          final dateText = state.value != null
              ? '${state.value!.year}-${state.value!.month.toString().padLeft(2, '0')}-${state.value!.day.toString().padLeft(2, '0')}'
              : '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    state.didChange(picked);
                    onDateChanged(picked);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller:
                        TextEditingController(text: dateText),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText:
                          '${field.label}${field.required ? ' *' : ''}',
                      hintText: l10n.selectDate,
                      suffixIcon: const Icon(
                          Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: state.errorText,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // ── Number
    if (type == 'number') {
      return AppTextField(
        controller: textController!,
        label: '${field.label}${field.required ? ' *' : ''}',
        hint: field.placeholder ?? field.label,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: false,
        ),
        validator: (v) => _validateNumber(v, context),
      );
    }

    // ── Text / textarea / email / phone (default)
    if (type == 'textfield' ||
        type == 'text' ||
        type == 'textarea' ||
        type == 'email' ||
        type == 'phone' ||
        type == 'string') {
      return AppTextField(
        controller: textController!,
        label: '${field.label}${field.required ? ' *' : ''}',
        hint: field.placeholder ?? field.label,
        maxLines: type == 'textarea' ? 4 : 1,
        keyboardType: type == 'email'
            ? TextInputType.emailAddress
            : type == 'phone'
                ? TextInputType.phone
                : TextInputType.text,
        validator: (v) => _validateText(v, context),
      );
    }

    // ── Unsupported
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.errorContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${field.label} (unsupported type: $type)',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onErrorContainer,
        ),
      ),
    );
  }
}
