import 'dart:convert';

import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _submitting = false;

  Map<String, dynamic> _formJson = <String, dynamic>{};
  Map<String, dynamic> _schema = <String, dynamic>{};
  List<Map<String, dynamic>> _components = [];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _checkboxValues = {};
  final Map<String, String?> _selectValues = {};

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
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

      final parsedSchema = _parseSchema(form);
      final components = _extractComponents(parsedSchema);

      _initComponentState(components);

      setState(() {
        _formJson = form;
        _schema = parsedSchema;
        _components = components;
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

  Map<String, dynamic> _parseSchema(Map<String, dynamic> form) {
    final rawSchema = form['schema'];

    if (rawSchema is Map) {
      return Map<String, dynamic>.from(rawSchema);
    }

    if (rawSchema is String && rawSchema.trim().isNotEmpty) {
      final decoded = jsonDecode(rawSchema);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractComponents(Map<String, dynamic> schema) {
    final rawComponents = schema['components'];

    if (rawComponents is! List) {
      return [];
    }

    return rawComponents
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((component) {
      final key = component['key']?.toString().trim() ?? '';
      final type = component['type']?.toString().trim() ?? '';
      return key.isNotEmpty && type.isNotEmpty;
    }).toList();
  }

  void _initComponentState(List<Map<String, dynamic>> components) {
    for (final component in components) {
      final key = component['key']?.toString().trim() ?? '';
      final type = component['type']?.toString().trim().toLowerCase() ?? '';
      final defaultValue = component['defaultValue'];

      if (key.isEmpty) continue;

      if (_isTextLike(type) || type == 'number') {
        _controllers[key] = TextEditingController(
          text: defaultValue?.toString() ?? '',
        );
      } else if (type == 'checkbox') {
        _checkboxValues[key] = defaultValue == true;
      } else if (_isSelectLike(type)) {
        _selectValues[key] = defaultValue?.toString();
      }
    }
  }

  bool _isTextLike(String type) {
    return type == 'textfield' ||
        type == 'text' ||
        type == 'textarea' ||
        type == 'email' ||
        type == 'phone';
  }

  bool _isSelectLike(String type) {
    return type == 'select' ||
        type == 'radio' ||
        type == 'dropdown' ||
        type == 'checklist';
  }

  bool _isRequired(Map<String, dynamic> component) {
    final validate = component['validate'];

    if (validate is Map) {
      return validate['required'] == true;
    }

    return component['required'] == true;
  }

  String _labelOf(Map<String, dynamic> component) {
    final label = component['label']?.toString().trim() ?? '';
    final key = component['key']?.toString().trim() ?? '';
    return label.isNotEmpty ? label : key;
  }

  List<Map<String, dynamic>> _valuesOf(Map<String, dynamic> component) {
    final values = component['values'];

    if (values is! List) {
      return [];
    }

    return values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    final taskId = widget.task.id;

    if (taskId == null) {
      AppToast.show(
        context,
        message: l10n.noFormFound,
        type: AppToastType.error,
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final variables = <String, dynamic>{};

    for (final component in _components) {
      final key = component['key']?.toString().trim() ?? '';
      final type = component['type']?.toString().trim().toLowerCase() ?? '';

      if (key.isEmpty) continue;

      if (type == 'number') {
        final rawValue = _controllers[key]?.text.trim() ?? '';

        if (rawValue.isEmpty) {
          variables[key] = null;
        } else {
          final intValue = int.tryParse(rawValue);
          final doubleValue = double.tryParse(rawValue);

          variables[key] = intValue ?? doubleValue ?? rawValue;
        }
      } else if (_isTextLike(type)) {
        variables[key] = _controllers[key]?.text.trim() ?? '';
      } else if (type == 'checkbox') {
        variables[key] = _checkboxValues[key] ?? false;
      } else if (_isSelectLike(type)) {
        variables[key] = _selectValues[key];
      }
    }

    setState(() {
      _submitting = true;
    });

    try {
      final api = widget.apiService ?? StaffTaskApiService();

      await api.completeTask(
        taskId: taskId,
        variables: variables,
      );

      if (!mounted) return;

      AppToast.show(
        context,
        message: l10n.formSubmittedSuccessfully,
        type: AppToastType.success,
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      AppToast.show(
        context,
        message: errorMessage(e),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Widget _buildField(Map<String, dynamic> component) {
    final l10n = AppLocalizations.of(context)!;
    final type = component['type']?.toString().trim().toLowerCase() ?? '';
    final key = component['key']?.toString().trim() ?? '';
    final label = _labelOf(component);
    final required = _isRequired(component);

    if (type == 'number') {
      return AppTextField(
        controller: _controllers[key]!,
        label: label,
        hint: label,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: false,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              }
            : null,
      );
    }

    if (_isTextLike(type)) {
      return AppTextField(
        controller: _controllers[key]!,
        label: label,
        hint: label,
        maxLines: type == 'textarea' ? 4 : 1,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              }
            : null,
      );
    }

    if (type == 'checkbox') {
      final theme = Theme.of(context);
      final cs = theme.colorScheme;

      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: CheckboxListTile(
          value: _checkboxValues[key] ?? false,
          title: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _checkboxValues[key] = value ?? false;
            });
          },
        ),
      );
    }

    if (_isSelectLike(type)) {
      final values = _valuesOf(component);

      return DropdownButtonFormField<String>(
        value: _selectValues[key],
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              }
            : null,
        items: values.map((item) {
          final itemLabel = item['label']?.toString() ??
              item['name']?.toString() ??
              item['value']?.toString() ??
              '';

          final itemValue = item['value']?.toString() ?? itemLabel;

          return DropdownMenuItem<String>(
            value: itemValue,
            child: Text(itemLabel),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectValues[key] = value;
          });
        },
      );
    }

    return _UnsupportedField(
      label: '$label (${l10n.unsupportedFieldType}: $type)',
    );
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
            : _formJson.isEmpty || _schema.isEmpty || _components.isEmpty
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _formJson['formId']?.toString() ?? l10n.taskForm,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._components.map(
                              (component) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildField(component),
                              ),
                            ),
                            const SizedBox(height: 8),
                            PrimaryButton(
                              label: l10n.submitTaskForm,
                              isLoading: _submitting,
                              onPressed: _submitForm,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _UnsupportedField extends StatelessWidget {
  final String label;

  const _UnsupportedField({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}