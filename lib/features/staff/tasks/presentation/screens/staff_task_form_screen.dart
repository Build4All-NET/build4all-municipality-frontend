import 'dart:convert';


import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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

class _StaffTaskFormScreenState extends State<StaffTaskFormScreen> {
  bool _loading = true;
  Map<String, dynamic> _formJson = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    final taskId = widget.task.id;

    if (taskId == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final api = widget.apiService ?? StaffTaskApiService();

      final form = await api.getTaskForm(taskId);

      if (!mounted) return;

      setState(() {
        _formJson = form;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      AppToast.show(
        context,
        message: errorMessage(e),
        type: AppToastType.error,
      );
    }
  }

  String _prettyJson(Map<String, dynamic> json) {
    if (json.isEmpty) return '{}';

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskForm),
      ),
      body: SafeArea(
        child: _loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      l10n.loadingForm,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _formJson.isEmpty
                ? Center(
                    child: Text(
                      l10n.noFormFound,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rawFormJson,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _prettyJson(_formJson),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}