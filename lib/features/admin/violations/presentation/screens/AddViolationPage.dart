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
import 'package:baladiyati/features/admin/violations/presentation/widgets/violation_category_dropdown.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateViolationScreen extends StatefulWidget {
  final Violation? violation;

  const CreateViolationScreen({super.key, this.violation});

  bool get isEdit => violation != null;

  @override
  State<CreateViolationScreen> createState() => _CreateViolationScreenState();
}

class _CreateViolationScreenState extends State<CreateViolationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _citizenNameController;
  late final TextEditingController _identityNumberController;
  late final TextEditingController _carPlateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _amountController;

  final DepartmentApiService _departmentApiService =
      DepartmentApiService(DioClient.muni);

  List<DepartmentModel> _departments = [];
  int? _selectedDepartmentId;
  String? _selectedType;

  bool _loadingDepartments = true;
  DateTime? _selectedDate;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    final v = widget.violation;

    _titleController = TextEditingController(text: v?.title ?? '');
    _citizenNameController = TextEditingController(text: v?.citizenName ?? '');
    _identityNumberController = TextEditingController(text: v?.identityNumber ?? '');
    _carPlateController = TextEditingController(text: v?.carPlate ?? '');
    _descriptionController = TextEditingController(text: v?.description ?? '');
    _locationController = TextEditingController(text: v?.location ?? '');
    _amountController = TextEditingController(
      text: v == null ? '' : v.amount.toString(),
    );

    _selectedDepartmentId =
        (v != null && v.departmentId > 0) ? v.departmentId : null;
    _selectedDate = _parseDate(v?.violationDate);
    _selectedType = v?.type;

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDepartments());
  }

  Future<void> _loadDepartments() async {
    if (!mounted) return;

    setState(() => _loadingDepartments = true);

    try {
      final data = await _departmentApiService.getAll();

      if (!mounted) return;

      setState(() {
        _departments = data;
        _loadingDepartments = false;

        if (_selectedDepartmentId == null && data.isNotEmpty) {
          _selectedDepartmentId = data.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _departments = [];
        _loadingDepartments = false;
      });

      AppToast.show(context, message: errorMessage(e), type: AppToastType.error);
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _citizenNameController.dispose();
    _identityNumberController.dispose();
    _carPlateController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  String _formatDateForBackend(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateForUi(DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  // ─── Validators ──────────────────────────────────────────────────────────────

  String? _required(String? value) {
    final loc = AppLocalizations.of(context)!;
    return (value?.trim() ?? '').isEmpty ? loc.fieldRequired : null;
  }

  String? _required3to25(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return loc.fieldRequired;
    if (text.length < 3 || text.length > 25) return loc.characters3To25;
    return null;
  }

  String? _positiveNumber(String? value) {
    final loc = AppLocalizations.of(context)!;
    final n = double.tryParse(value?.trim() ?? '');
    return (n == null || n <= 0) ? loc.invalidAmount : null;
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  void _submit() {
    final loc = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    // Department is required
    if (_selectedDepartmentId == null || _selectedDepartmentId! <= 0) {
      AppToast.show(context, message: loc.selectDepartment, type: AppToastType.warning);
      return;
    }

    // Type is required
    if (_selectedType == null || _selectedType!.isEmpty) {
      AppToast.show(context, message: loc.selectViolationType, type: AppToastType.warning);
      return;
    }

    // Date is required
    if (_selectedDate == null) {
      AppToast.show(context, message: loc.pleaseSelectDate, type: AppToastType.error);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      AppToast.show(context, message: loc.invalidAmount, type: AppToastType.error);
      return;
    }

    // Identifier validation: at least identityNumber or carPlate must be provided.
    // Name alone is not a valid identifier.
    final name = _citizenNameController.text.trim();
    final identity = _identityNumberController.text.trim();
    final plate = _carPlateController.text.trim();

    if (identity.isEmpty && plate.isEmpty) {
      AppToast.show(
        context,
        message: loc.identifierRequired,
        type: AppToastType.warning,
      );
      return;
    }

    if (name.isNotEmpty && identity.isEmpty && plate.isEmpty) {
      AppToast.show(
        context,
        message: loc.nameRequiresIdentifier,
        type: AppToastType.warning,
      );
      return;
    }

    final violation = Violation(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      citizenName: name,
      identityNumber: identity.isEmpty ? null : identity,
      carPlate: plate.isEmpty ? null : plate,
      amount: amount,
      departmentId: _selectedDepartmentId!,
      location: _locationController.text.trim(),
      violationDate: _formatDateForBackend(_selectedDate!),
      type: _selectedType,
    );

    setState(() => _submitted = true);

    if (widget.isEdit) {
      final id = widget.violation?.id;

      if (id == null) {
        setState(() => _submitted = false);
        AppToast.show(context, message: loc.missingViolationId, type: AppToastType.error);
        return;
      }

      context.read<ViolationBloc>().add(
            UpdateViolationEvent(id: id, violation: violation),
          );
    } else {
      context.read<ViolationBloc>().add(CreateViolationEvent(violation));
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

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
          setState(() => _submitted = false);
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
          title: Text(widget.isEdit ? loc.editViolation : loc.createViolation),
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
                      title: widget.isEdit ? loc.editViolation : loc.createViolation,
                      subtitle: widget.isEdit
                          ? loc.violationEditHint
                          : loc.violationCreateHint,
                    ),

                    const SizedBox(height: 16),

                    // ── Violation title ──────────────────────────────────────
                    _InputField(
                      label: loc.violationTitle,
                      hint: loc.enterViolationTitle,
                      controller: _titleController,
                      icon: Icons.title_outlined,
                      validator: _required3to25,
                      enabled: !isLoading,
                    ),

                    // ── Type dropdown ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ViolationCategoryDropdown(
                        value: _selectedType,
                        label: loc.violationType,
                        enabled: !isLoading,
                        onChanged: (v) => setState(() => _selectedType = v),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? loc.fieldRequired : null,
                      ),
                    ),

                    // ── Description ─────────────────────────────────────────
                    _InputField(
                      label: loc.description,
                      hint: loc.enterDescription,
                      controller: _descriptionController,
                      icon: Icons.description_outlined,
                      minLines: 3,
                      maxLines: 5,
                      validator: _required,
                      enabled: !isLoading,
                    ),

                    // ── Location ─────────────────────────────────────────────
                    _InputField(
                      label: loc.location,
                      hint: loc.enterLocation,
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                      validator: _required3to25,
                      enabled: !isLoading,
                    ),

                    // ── Department dropdown ──────────────────────────────────
                    _DepartmentDropdown(
                      loading: _loadingDepartments,
                      value: _selectedDepartmentId,
                      departments: _departments,
                      enabled: !isLoading,
                      onChanged: (v) => setState(() => _selectedDepartmentId = v),
                      onRefresh: _loadDepartments,
                    ),

                    const SizedBox(height: 12),

                    // ── Date picker ──────────────────────────────────────────
                    _DateField(
                      label: loc.date,
                      value: _selectedDate == null
                          ? loc.selectDate
                          : _formatDateForUi(_selectedDate!),
                      hasValue: _selectedDate != null,
                      onTap: isLoading ? null : _pickDate,
                    ),

                    const SizedBox(height: 12),

                    // ── Amount ───────────────────────────────────────────────
                    _InputField(
                      label: loc.amount,
                      hint: loc.enterAmount,
                      controller: _amountController,
                      icon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: _positiveNumber,
                      enabled: !isLoading,
                    ),

                    const _SectionDivider(label: 'Citizen Identification'),

                    // ── Citizen name (optional) ──────────────────────────────
                    _InputField(
                      label: loc.citizenName,
                      hint: loc.enterCitizenName,
                      controller: _citizenNameController,
                      icon: Icons.person_outline,
                      validator: null,
                      enabled: !isLoading,
                    ),

                    // ── Identity number (at least one of these required) ─────
                    _InputField(
                      label: loc.identityNumber,
                      hint: loc.enterIdentityNumber,
                      controller: _identityNumberController,
                      icon: Icons.badge_outlined,
                      validator: null,
                      enabled: !isLoading,
                    ),

                    // ── Car plate ────────────────────────────────────────────
                    _InputField(
                      label: loc.carPlate,
                      hint: loc.enterCarPlate,
                      controller: _carPlateController,
                      icon: Icons.directions_car_outlined,
                      validator: null,
                      enabled: !isLoading,
                    ),

                    _IdentifierHint(),

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

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FormHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.14),
            child: Icon(Icons.gavel_outlined, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
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

class _SectionDivider extends StatelessWidget {
  final String label;

  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.outline.withOpacity(0.3))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.55),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: Divider(color: colors.outline.withOpacity(0.3))),
        ],
      ),
    );
  }
}

class _IdentifierHint extends StatelessWidget {
  const _IdentifierHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.tertiary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.tertiary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: colors.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'At least Identity Number or Car Plate is required. Name alone is not sufficient.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Expanded(child: Text(loc.loadingDepartments)),
          ],
        ),
      );
    }

    if (departments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.error.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(loc.noDepartmentsHint)),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              iconSize: 20,
            ),
          ],
        ),
      );
    }

    final hasValue = value != null && departments.any((d) => d.id == value);

    return DropdownButtonFormField<int>(
      value: hasValue ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: loc.department,
        prefixIcon: const Icon(Icons.account_tree_outlined),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.22)),
        ),
      ),
      items: departments
          .map((d) => DropdownMenuItem<int>(value: d.id, child: Text(d.name)))
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: (v) => (v == null || v <= 0) ? loc.selectDepartment : null,
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.outline.withOpacity(0.22)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.outline.withOpacity(0.22)),
          ),
        ),
        child: Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasValue ? colors.onSurface : colors.onSurface.withOpacity(0.56),
          ),
        ),
      ),
    );
  }
}
