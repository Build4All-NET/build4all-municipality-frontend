import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/env.dart';
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

// Backend enum values — must be sent exactly as listed.
const _kViolationTypes = [
  'TRAFFIC',
  'ENVIRONMENTAL',
  'URBANISM',
  'COMMERCIAL',
  'OTHER',
];

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
  DateTime? _selectedDate;

  bool _loadingDepartments = true;
  bool _submitted = false;

  // Whether each identifier section is required based on the selected type
  bool get _isTraffic => _selectedType == 'TRAFFIC';

  @override
  void initState() {
    super.initState();
    final v = widget.violation;

    _titleController = TextEditingController(text: v?.title ?? '');
    _citizenNameController = TextEditingController(text: v?.citizenName ?? '');
    _identityNumberController =
        TextEditingController(text: v?.identityNumber ?? '');
    _carPlateController = TextEditingController(text: v?.carPlate ?? '');
    _descriptionController = TextEditingController(text: v?.description ?? '');
    _locationController = TextEditingController(text: v?.location ?? '');
    _amountController = TextEditingController(
        text: v == null ? '' : v.amount.toString());

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
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = picked);
  }

  String _formatDateForBackend(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateForUi(DateTime date) =>
      MaterialLocalizations.of(context).formatMediumDate(date);

  // ─── Validators ────────────────────────────────────────────────────────────

  String? _required(String? value) {
    final loc = AppLocalizations.of(context)!;
    return (value?.trim() ?? '').isEmpty ? loc.fieldRequired : null;
  }

  String? _required3to100(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return loc.fieldRequired;
    if (text.length < 3) return loc.characters3To25;
    return null;
  }

  String? _positiveNumber(String? value) {
    final loc = AppLocalizations.of(context)!;
    final n = double.tryParse(value?.trim() ?? '');
    return (n == null || n <= 0) ? loc.invalidAmount : null;
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  void _submit() {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null || _selectedType!.isEmpty) {
      AppToast.show(context,
          message: loc.selectViolationType, type: AppToastType.warning);
      return;
    }

    if (_selectedDepartmentId == null || _selectedDepartmentId! <= 0) {
      AppToast.show(context,
          message: loc.selectDepartment, type: AppToastType.warning);
      return;
    }

    if (_selectedDate == null) {
      AppToast.show(context,
          message: loc.pleaseSelectDate, type: AppToastType.error);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      AppToast.show(context,
          message: loc.invalidAmount, type: AppToastType.error);
      return;
    }

    final name = _citizenNameController.text.trim();
    final identity = _identityNumberController.text.trim();
    final plate = _carPlateController.text.trim();

    // TRAFFIC: carPlate is required
    if (_isTraffic && plate.isEmpty) {
      AppToast.show(context,
          message: loc.carPlateRequired, type: AppToastType.warning);
      return;
    }

    // All other types: at least one identifier must be provided
    if (!_isTraffic && name.isEmpty && identity.isEmpty && plate.isEmpty) {
      AppToast.show(context,
          message: loc.identifierRequired, type: AppToastType.warning);
      return;
    }

    // Read municipality ID from app configuration
    final municipalityId = int.tryParse(Env.ownerProjectLinkId.trim());
    if (municipalityId == null || municipalityId <= 0) {
      AppToast.show(context,
          message: loc.missingMunicipalityId, type: AppToastType.error);
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
      municipalityId: municipalityId,
    );

    setState(() => _submitted = true);

    if (widget.isEdit) {
      final id = widget.violation?.id;
      if (id == null) {
        setState(() => _submitted = false);
        AppToast.show(context,
            message: loc.missingViolationId, type: AppToastType.error);
        return;
      }
      context.read<ViolationBloc>().add(
            UpdateViolationEvent(id: id, violation: violation),
          );
    } else {
      context.read<ViolationBloc>().add(CreateViolationEvent(violation));
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<ViolationBloc, ViolationState>(
      listener: (context, state) {
        if (!_submitted) return;
        if (state is ViolationLoaded) {
          AppToast.show(context,
              message: loc.violationSaved, type: AppToastType.success);
          Navigator.pop(context);
        }
        if (state is ViolationError) {
          setState(() => _submitted = false);
          AppToast.show(context,
              message: state.message, type: AppToastType.error);
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page header ──────────────────────────────────────────
                    _PageHeader(isEdit: widget.isEdit),

                    const SizedBox(height: 16),

                    // ── Section 1: Violation Type ────────────────────────────
                    _SectionCard(
                      icon: Icons.category_outlined,
                      title: loc.violationType,
                      child: _TypeDropdown(
                        value: _selectedType,
                        enabled: !isLoading,
                        onChanged: (v) =>
                            setState(() => _selectedType = v),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? loc.fieldRequired : null,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Section 2: Violation Details ─────────────────────────
                    _SectionCard(
                      icon: Icons.gavel_outlined,
                      title: loc.violationDetails,
                      child: Column(
                        children: [
                          _InputField(
                            label: loc.violationTitle,
                            hint: loc.enterViolationTitle,
                            controller: _titleController,
                            icon: Icons.title_outlined,
                            validator: _required3to100,
                            enabled: !isLoading,
                          ),
                          _InputField(
                            label: loc.description,
                            hint: loc.enterDescription,
                            controller: _descriptionController,
                            icon: Icons.description_outlined,
                            minLines: 3,
                            maxLines: 6,
                            validator: _required,
                            enabled: !isLoading,
                          ),
                          _InputField(
                            label: loc.location,
                            hint: loc.enterLocation,
                            controller: _locationController,
                            icon: Icons.location_on_outlined,
                            validator: _required3to100,
                            enabled: !isLoading,
                          ),
                          _DateField(
                            label: loc.date,
                            value: _selectedDate == null
                                ? loc.selectDate
                                : _formatDateForUi(_selectedDate!),
                            hasValue: _selectedDate != null,
                            onTap: isLoading ? null : _pickDate,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Section 3: Citizen / Vehicle Information ─────────────
                    // Fields shown depend on the selected violation type
                    if (_selectedType != null)
                      _CitizenSection(
                        type: _selectedType!,
                        isLoading: isLoading,
                        nameController: _citizenNameController,
                        identityController: _identityNumberController,
                        plateController: _carPlateController,
                        requiredValidator: _required,
                      ),

                    if (_selectedType == null) ...[
                      _SectionCard(
                        icon: Icons.person_outline,
                        title: loc.citizenInfo,
                        child: _HintRow(
                          message: loc.selectTypeFirst,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // ── Section 4: Payment & Assignment ─────────────────────
                    _SectionCard(
                      icon: Icons.payments_outlined,
                      title: loc.paymentAndAssignment,
                      child: Column(
                        children: [
                          _InputField(
                            label: loc.amount,
                            hint: loc.enterAmount,
                            controller: _amountController,
                            icon: Icons.attach_money_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            validator: _positiveNumber,
                            enabled: !isLoading,
                          ),
                          _DepartmentDropdown(
                            loading: _loadingDepartments,
                            value: _selectedDepartmentId,
                            departments: _departments,
                            enabled: !isLoading,
                            onChanged: (v) =>
                                setState(() => _selectedDepartmentId = v),
                            onRefresh: _loadDepartments,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
// Citizen section — dynamic based on violation type
// ─────────────────────────────────────────────────────────────────────────────

class _CitizenSection extends StatelessWidget {
  final String type;
  final bool isLoading;
  final TextEditingController nameController;
  final TextEditingController identityController;
  final TextEditingController plateController;
  final String? Function(String?) requiredValidator;

  const _CitizenSection({
    required this.type,
    required this.isLoading,
    required this.nameController,
    required this.identityController,
    required this.plateController,
    required this.requiredValidator,
  });

  bool get _showPlate => type == 'TRAFFIC' || type == 'COMMERCIAL' || type == 'OTHER';
  bool get _showName => type != 'TRAFFIC' || type == 'OTHER';
  bool get _plateRequired => type == 'TRAFFIC';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final String sectionTitle;
    final IconData sectionIcon;

    switch (type) {
      case 'TRAFFIC':
        sectionTitle = loc.vehicleInfo;
        sectionIcon = Icons.directions_car_outlined;
      case 'COMMERCIAL':
        sectionTitle = loc.businessOwnerInfo;
        sectionIcon = Icons.store_outlined;
      default:
        sectionTitle = loc.citizenInfo;
        sectionIcon = Icons.person_outline;
    }

    return _SectionCard(
      icon: sectionIcon,
      title: sectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car plate — top for TRAFFIC (required), optional for others that show it
          if (_showPlate)
            _InputField(
              label: _plateRequired
                  ? '${loc.carPlate} *'
                  : loc.carPlate,
              hint: loc.enterCarPlate,
              controller: plateController,
              icon: Icons.directions_car_outlined,
              validator: _plateRequired ? requiredValidator : null,
              enabled: !isLoading,
            ),

          // Identity number — optional for all types
          _InputField(
            label: loc.identityNumber,
            hint: loc.enterIdentityNumber,
            controller: identityController,
            icon: Icons.badge_outlined,
            validator: null,
            enabled: !isLoading,
          ),

          // Citizen / owner name — optional for TRAFFIC, relevant for others
          if (_showName || type == 'TRAFFIC')
            _InputField(
              label: type == 'COMMERCIAL'
                  ? loc.businessOwnerName
                  : loc.citizenName,
              hint: loc.enterCitizenName,
              controller: nameController,
              icon: Icons.person_outline,
              validator: null,
              enabled: !isLoading,
            ),

          // Hint about identifier requirements
          _IdentifierHint(type: type),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final bool isEdit;

  const _PageHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
                  isEdit ? loc.editViolation : loc.createViolation,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  isEdit ? loc.violationEditHint : loc.violationCreateHint,
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

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: colors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.outline.withOpacity(0.10),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _TypeDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: loc.violationType,
        prefixIcon: const Icon(Icons.category_outlined),
        filled: true,
        fillColor: colors.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.22)),
        ),
      ),
      items: _kViolationTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}

class _IdentifierHint extends StatelessWidget {
  final String type;

  const _IdentifierHint({required this.type});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final message = type == 'TRAFFIC'
        ? loc.trafficIdentifierHint
        : loc.generalIdentifierHint;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 13, color: colors.outline),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.56),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final String message;

  const _HintRow({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: colors.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.56),
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
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
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
          borderRadius: BorderRadius.circular(12),
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
                iconSize: 20),
          ],
        ),
      );
    }

    final hasValue = value != null && departments.any((d) => d.id == value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: hasValue ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: loc.department,
          prefixIcon: const Icon(Icons.account_tree_outlined),
          filled: true,
          fillColor: colors.surfaceContainerLowest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.outline.withOpacity(0.22)),
          ),
        ),
        items: departments
            .map((d) =>
                DropdownMenuItem<int>(value: d.id, child: Text(d.name)))
            .toList(),
        onChanged: enabled ? onChanged : null,
        validator: (v) =>
            (v == null || v <= 0) ? loc.selectDepartment : null,
      ),
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
          fillColor: colors.surfaceContainerLowest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_month_outlined),
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: colors.outline.withOpacity(0.22)),
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
      ),
    );
  }
}
