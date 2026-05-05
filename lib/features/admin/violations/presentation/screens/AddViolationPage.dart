import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_bloc.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateViolationScreen extends StatefulWidget {
  final Violation? violation;

  const CreateViolationScreen({
    super.key,
    this.violation,
  });

  bool get isEdit => violation != null;

  @override
  State<CreateViolationScreen> createState() => _CreateViolationScreenState();
}

class _CreateViolationScreenState extends State<CreateViolationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController citizenNameController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;
  late final TextEditingController amountController;

  final DepartmentApiService _departmentApiService =
      DepartmentApiService(DioClient.muni);

  List<DepartmentModel> departments = [];
  int? selectedDepartmentId;

  bool loadingDepartments = true;
  DateTime? selectedDate;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    final violation = widget.violation;

    titleController = TextEditingController(text: violation?.title ?? '');
    citizenNameController = TextEditingController(
      text: violation?.citizenName ?? '',
    );
    descriptionController = TextEditingController(
      text: violation?.description ?? '',
    );
    locationController = TextEditingController(
      text: violation?.location ?? '',
    );
    amountController = TextEditingController(
      text: violation == null ? '' : violation.amount.toString(),
    );

    selectedDepartmentId =
        violation != null && violation.departmentId > 0
            ? violation.departmentId
            : null;

    selectedDate = _parseDate(violation?.violationDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDepartments();
    });
  }

  Future<void> _loadDepartments() async {
    if (!mounted) return;

    setState(() {
      loadingDepartments = true;
    });

    try {
      final data = await _departmentApiService.getAll();

      if (!mounted) return;

      setState(() {
        departments = data;
        loadingDepartments = false;

        if (selectedDepartmentId == null && data.isNotEmpty) {
          selectedDepartmentId = data.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        departments = [];
        loadingDepartments = false;
      });

      AppToast.show(
        context,
        message: errorMessage(e),
        type: AppToastType.error,
      );
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  @override
  void dispose() {
    titleController.dispose();
    citizenNameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  void _submit() {
    final loc = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (selectedDepartmentId == null || selectedDepartmentId! <= 0) {
      AppToast.show(
        context,
        message: loc.selectDepartment,
        type: AppToastType.warning,
      );
      return;
    }

    if (selectedDate == null) {
      AppToast.show(
        context,
        message: loc.pleaseSelectDate,
        type: AppToastType.error,
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      AppToast.show(
        context,
        message: loc.invalidAmount,
        type: AppToastType.error,
      );
      return;
    }

    final violation = Violation(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      citizenName: citizenNameController.text.trim(),
      amount: amount,
      departmentId: selectedDepartmentId!,
      location: locationController.text.trim(),
      violationDate: _formatDateForBackend(selectedDate!),
    );

    setState(() {
      _submitted = true;
    });

    if (widget.isEdit) {
      final id = widget.violation?.id;

      if (id == null) {
        setState(() {
          _submitted = false;
        });

        AppToast.show(
          context,
          message: loc.missingViolationId,
          type: AppToastType.error,
        );
        return;
      }

      context.read<ViolationBloc>().add(
            UpdateViolationEvent(
              id: id,
              violation: violation,
            ),
          );
    } else {
      context.read<ViolationBloc>().add(
            CreateViolationEvent(violation),
          );
    }
  }

  String _formatDateForBackend(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatDateForUi(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  String? _required(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';

    if (text.isEmpty) return loc.fieldRequired;

    return null;
  }

  String? _required3To25(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';

    if (text.isEmpty) return loc.fieldRequired;

    if (text.length < 3 || text.length > 25) {
      return loc.characters3To25;
    }

    return null;
  }

  String? _positiveNumber(String? value) {
    final loc = AppLocalizations.of(context)!;
    final number = double.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return loc.invalidAmount;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<ViolationBloc, ViolationState>(
      listener: (context, state) {
        if (!_submitted) return;

        if (state is ViolationLoaded) {
          AppToast.show(
            context,
            message: loc.violationSaved,
            type: AppToastType.success,
          );

          Navigator.pop(context);
        }

        if (state is ViolationError) {
          setState(() {
            _submitted = false;
          });

          AppToast.show(
            context,
            message: state.message,
            type: AppToastType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.isEdit ? loc.editViolation : loc.createViolation,
          ),
        ),
        body: BlocBuilder<ViolationBloc, ViolationState>(
          builder: (context, state) {
            final isLoading = _submitted && state is ViolationLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _FormHeader(
                      title: widget.isEdit
                          ? loc.editViolation
                          : loc.createViolation,
                      subtitle: widget.isEdit
                          ? loc.violationEditHint
                          : loc.violationCreateHint,
                    ),

                    const SizedBox(height: 16),

                    _InputField(
                      label: loc.name,
                      hint: loc.enterName,
                      controller: titleController,
                      icon: Icons.gavel_outlined,
                      validator: _required3To25,
                      enabled: !isLoading,
                    ),

                    _InputField(
                      label: loc.citizenName,
                      hint: loc.enterCitizenName,
                      controller: citizenNameController,
                      icon: Icons.person_outline,
                      validator: _required,
                      enabled: !isLoading,
                    ),

                    _InputField(
                      label: loc.description,
                      hint: loc.enterDescription,
                      controller: descriptionController,
                      icon: Icons.description_outlined,
                      minLines: 3,
                      maxLines: 5,
                      validator: _required,
                      enabled: !isLoading,
                    ),

                    _InputField(
                      label: loc.location,
                      hint: loc.enterLocation,
                      controller: locationController,
                      icon: Icons.location_on_outlined,
                      validator: _required3To25,
                      enabled: !isLoading,
                    ),

                    _DepartmentDropdown(
                      loading: loadingDepartments,
                      value: selectedDepartmentId,
                      departments: departments,
                      enabled: !isLoading,
                      onChanged: (value) {
                        setState(() {
                          selectedDepartmentId = value;
                        });
                      },
                      onRefresh: _loadDepartments,
                    ),

                    const SizedBox(height: 12),

                    _DateField(
                      label: loc.date,
                      value: selectedDate == null
                          ? loc.selectDate
                          : _formatDateForUi(context, selectedDate!),
                      hasValue: selectedDate != null,
                      onTap: isLoading ? null : _pickDate,
                    ),

                    const SizedBox(height: 12),

                    _InputField(
                      label: loc.amount,
                      hint: loc.enterAmount,
                      controller: amountController,
                      icon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: _positiveNumber,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      label: widget.isEdit ? loc.saveChanges : loc.create,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DepartmentDropdown extends StatelessWidget {
  final bool loading;
  final int? value;
  final List<DepartmentModel> departments;
  final bool enabled;
  final ValueChanged<int?> onChanged;
  final VoidCallback onRefresh;

  const _DepartmentDropdown({
    required this.loading,
    required this.value,
    required this.departments,
    required this.enabled,
    required this.onChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    if (loading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(loc.loadingDepartments),
            ),
          ],
        ),
      );
    }

    if (departments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.error.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(loc.noDepartmentsHint),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      );
    }

    final hasValue = value != null && departments.any((d) => d.id == value);
    final safeValue = hasValue ? value : null;

    return DropdownButtonFormField<int>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: loc.department,
        prefixIcon: const Icon(Icons.account_tree_outlined),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      items: departments.map((department) {
        return DropdownMenuItem<int>(
          value: department.id,
          child: Text(department.name),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (selected) {
        if (selected == null || selected <= 0) {
          return loc.selectDepartment;
        }

        return null;
      },
    );
  }
}

class _FormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FormHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.14),
            child: Icon(
              Icons.gavel_outlined,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.66),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int minLines;
  final int maxLines;
  final bool enabled;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isMultiline = maxLines > 1 || minLines > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
        inputFormatters: inputFormatters,
        minLines: minLines,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        textInputAction: isMultiline ? null : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colors.outline.withOpacity(0.22),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback? onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colors.outline.withOpacity(0.22),
            ),
          ),
        ),
        child: Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasValue
                ? colors.onSurface
                : colors.onSurface.withOpacity(0.56),
          ),
        ),
      ),
    );
  }
}