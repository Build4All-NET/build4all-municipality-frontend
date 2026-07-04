import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_State.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_bloc.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_event.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddServicePage extends StatefulWidget {
  final ServiceModel? service;

  const AddServicePage({
    super.key,
    this.service,
  });

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameArController;
  late final TextEditingController nameEnController;
  late final TextEditingController descriptionArController;
  late final TextEditingController descriptionEnController;
  late final TextEditingController slaDaysController;
  late final TextEditingController feeAmountController;

  final DepartmentApiService _departmentApiService =
      DepartmentApiService(DioClient.muni);

  List<DepartmentModel> departments = [];

  int? selectedDepartmentId;

  bool loadingDepartments = true;
  bool requiresInspection = false;
  bool hasFees = false;
  bool isActive = true;
  bool submitting = false;

  bool get isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();

    final service = widget.service;

    selectedDepartmentId =
        service != null && service.departmentId > 0 ? service.departmentId : null;

    nameArController = TextEditingController(text: service?.nameAr ?? '');
    nameEnController = TextEditingController(text: service?.nameEn ?? '');

    descriptionArController = TextEditingController(
      text: service?.descriptionAr ?? '',
    );

    descriptionEnController = TextEditingController(
      text: service?.descriptionEn ?? '',
    );

    slaDaysController = TextEditingController(
      text: service?.slaDays.toString() ?? '',
    );

    feeAmountController = TextEditingController(
      text: service == null || service.feeAmount == 0
          ? ''
          : service.feeAmount.toString(),
    );

    requiresInspection = service?.requiresInspection ?? false;
    hasFees = service?.hasFees ?? false;
    isActive = service?.isActive ?? true;

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

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    descriptionArController.dispose();
    descriptionEnController.dispose();
    slaDaysController.dispose();
    feeAmountController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    final loc = AppLocalizations.of(context)!;

    if ((value ?? '').trim().isEmpty) return loc.fieldRequired;

    return null;
  }

  String? _positiveInt(String? value) {
    final loc = AppLocalizations.of(context)!;
    final number = int.tryParse((value ?? '').trim());

    if (number == null || number <= 0) {
      return loc.invalidNumber;
    }

    return null;
  }

  String? _nonNegativeDouble(String? value) {
    final loc = AppLocalizations.of(context)!;

    if (!hasFees) return null;

    final number = double.tryParse((value ?? '').trim());

    if (number == null || number < 0) {
      return loc.invalidAmount;
    }

    return null;
  }

  int _resolveMunicipalityId() {
    // For edit: keep the existing municipalityId.
    // For create: send 0 for now and let the backend resolve municipality
    // from token / Owner-Project-Link-Id if supported.
    //
    // Later الأفضل نخلي backend ما يحتاج municipalityId من frontend أبداً.
    return widget.service?.municipalityId ?? 0;
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (selectedDepartmentId == null || selectedDepartmentId! <= 0) {
      AppToast.show(
        context,
        message: loc.selectDepartment,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    final service = ServiceModel(
      id: widget.service?.id ?? 0,
      municipalityId: _resolveMunicipalityId(),
      departmentId: selectedDepartmentId!,
      nameAr: nameArController.text.trim(),
      nameEn: nameEnController.text.trim(),
      descriptionAr: descriptionArController.text.trim(),
      descriptionEn: descriptionEnController.text.trim(),
      slaDays: int.parse(slaDaysController.text.trim()),
      requiresInspection: requiresInspection,
      hasFees: hasFees,
      feeAmount: hasFees
          ? double.tryParse(feeAmountController.text.trim()) ?? 0
          : 0,
      isActive: isActive,
    );

    final bloc = context.read<ServiceBloc>();

    if (isEdit) {
      bloc.add(
        UpdateServiceEvent(
          id: widget.service!.id,
          service: service,
        ),
      );
    } else {
      bloc.add(AddService(service));
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final state = bloc.state;

    if (state.error != null && state.error!.isNotEmpty) {
      setState(() {
        submitting = false;
      });

      return;
    }

    setState(() {
      submitting = false;
    });

    AppToast.show(
      context,
      message: isEdit ? loc.serviceUpdated : loc.serviceCreated,
      type: AppToastType.success,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<ServiceBloc, ServiceState>(
      listener: (context, state) {
        final error = state.error;

        if (error != null && error.isNotEmpty) {
          if (mounted) {
            setState(() {
              submitting = false;
            });
          }

          AppToast.show(
            context,
            message: error,
            type: AppToastType.error,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? loc.editService : loc.addService),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _HeaderCard(
                  title: isEdit ? loc.editService : loc.addService,
                  subtitle: loc.manageServices,
                ),

                const SizedBox(height: 16),

                _DepartmentDropdown(
                  loading: loadingDepartments,
                  value: selectedDepartmentId,
                  departments: departments,
                  onChanged: (value) {
                    setState(() {
                      selectedDepartmentId = value;
                    });
                  },
                  onRefresh: _loadDepartments,
                ),

                const SizedBox(height: 12),

                _InputField(
                  controller: nameArController,
                  label: loc.nameAr,
                  icon: Icons.language,
                  validator: _required,
                ),

                _InputField(
                  controller: nameEnController,
                  label: loc.nameEn,
                  icon: Icons.title_outlined,
                  validator: _required,
                ),

                _InputField(
                  controller: descriptionArController,
                  label: loc.descriptionAr,
                  icon: Icons.description_outlined,
                  minLines: 3,
                  maxLines: 5,
                  validator: _required,
                ),

                _InputField(
                  controller: descriptionEnController,
                  label: loc.descriptionEn,
                  icon: Icons.description_outlined,
                  minLines: 3,
                  maxLines: 5,
                  validator: _required,
                ),

                _InputField(
                  controller: slaDaysController,
                  label: loc.slaDays,
                  icon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                  validator: _positiveInt,
                ),

                SwitchListTile(
                  value: requiresInspection,
                  title: Text(loc.requiresInspection),
                  contentPadding: EdgeInsets.zero,
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            requiresInspection = value;
                          });
                        },
                ),

                SwitchListTile(
                  value: hasFees,
                  title: Text(loc.hasFees),
                  contentPadding: EdgeInsets.zero,
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            hasFees = value;

                            if (!value) {
                              feeAmountController.clear();
                            }
                          });
                        },
                ),

                if (hasFees)
                  _InputField(
                    controller: feeAmountController,
                    label: loc.price,
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _nonNegativeDouble,
                  ),

                SwitchListTile(
                  value: isActive,
                  title: Text(loc.active),
                  contentPadding: EdgeInsets.zero,
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                PrimaryButton(
                  label: isEdit ? loc.save : loc.add,
                  isLoading: submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DepartmentDropdown extends StatelessWidget {
  final bool loading;
  final int? value;
  final List<DepartmentModel> departments;
  final ValueChanged<int?> onChanged;
  final VoidCallback onRefresh;

  const _DepartmentDropdown({
    required this.loading,
    required this.value,
    required this.departments,
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
          child: Text(switch (department.name) {
            'Engineering' => loc.deptEngineering,
            'Finance' => loc.deptFinance,
            'Police' => loc.deptPolice,
            'Civil Status' => loc.deptCivilStatus,
            'Public Works' => loc.deptPublicWorks,
            _ => department.name,
          }),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (selected == null || selected <= 0) {
          return loc.selectDepartment;
        }

        return null;
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            color: colors.onPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
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
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final int minLines;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
  });

  bool get _isIntegerKeyboard => keyboardType == TextInputType.number;

  bool get _isDecimalKeyboard =>
      keyboardType is TextInputType &&
      keyboardType.toString().contains('decimal: true');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    List<TextInputFormatter>? formatters;

    if (_isIntegerKeyboard) {
      formatters = [FilteringTextInputFormatter.digitsOnly];
    } else if (_isDecimalKeyboard) {
      formatters = [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        minLines: minLines,
        maxLines: maxLines,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}