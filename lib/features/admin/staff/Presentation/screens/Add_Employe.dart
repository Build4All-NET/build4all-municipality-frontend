import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_State.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEmployeeDialog extends StatefulWidget {
  final Employee? employee;

  const AddEmployeeDialog({super.key, this.employee});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController roleIdController;

  int? selectedDep;
  bool submitting = false;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    nameController = TextEditingController(text: e?.name ?? '');
    emailController = TextEditingController(text: e?.email ?? '');
    phoneController = TextEditingController(text: e?.phone ?? '');
    roleIdController = TextEditingController(
      text: (e != null && e.roleId > 0) ? '${e.roleId}' : '',
    );
    selectedDep = (e != null && e.depId > 0) ? e.depId : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentCubit>().fetchDepartments();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    roleIdController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    final loc = AppLocalizations.of(context)!;
    if ((value?.trim() ?? '').isEmpty) return loc.fieldRequired;
    return null;
  }

  String? _emailValidator(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return loc.fieldRequired;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) return loc.invalidEmail;
    return null;
  }

  String? _positiveNumber(String? value) {
    final loc = AppLocalizations.of(context)!;
    final number = int.tryParse((value ?? '').trim());
    if (number == null || number <= 0) return loc.invalidNumber;
    return null;
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (selectedDep == null) {
      AppToast.show(context, message: loc.selectDepartment, type: AppToastType.warning);
      return;
    }

    setState(() { submitting = true; });

    final employee = Employee(
      id: _isEditing ? widget.employee!.id : null,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      depId: selectedDep!,
      roleId: int.parse(roleIdController.text.trim()),
    );

    if (_isEditing) {
      context.read<EmployeeBloc>().add(
        UpdateEmployee(id: widget.employee!.id!, employee: employee),
      );
    } else {
      context.read<EmployeeBloc>().add(AddEmployee(employee));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<EmployeeBloc, EmployeeState>(
      listener: (context, state) {
        final error = state.error;
        if (error != null && error.isNotEmpty) {
          setState(() { submitting = false; });
          AppToast.show(context, message: error, type: AppToastType.error);
          return;
        }
        if (submitting && !state.actionLoading) {
          setState(() { submitting = false; });
          AppToast.show(
            context,
            message: _isEditing ? loc.update : loc.employeeCreated,
            type: AppToastType.success,
          );
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          _isEditing ? loc.edit : loc.addEmployee,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        content: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditing && (widget.employee!.departmentName?.isNotEmpty == true))
                    _InfoRow(
                      label: loc.department,
                      value: switch (widget.employee!.departmentName) {
                        'Engineering' => loc.deptEngineering,
                        'Finance' => loc.deptFinance,
                        'Police' => loc.deptPolice,
                        'Civil Status' => loc.deptCivilStatus,
                        'Public Works' => loc.deptPublicWorks,
                        _ => widget.employee!.departmentName!,
                      },
                    ),
                  if (_isEditing && (widget.employee!.roleName?.isNotEmpty == true))
                    _InfoRow(
                      label: loc.role,
                      value: switch (widget.employee!.roleName) {
                        'OWNER' => loc.roleOwner,
                        'STAFF' => loc.roleStaff,
                        'USER' => loc.roleUser,
                        _ => widget.employee!.roleName!,
                      },
                    ),
                  if (_isEditing) const Divider(height: 24),
                  _InputField(
                    controller: nameController,
                    label: loc.name,
                    icon: Icons.person_outline,
                    validator: _required,
                  ),
                  _InputField(
                    controller: emailController,
                    label: loc.email,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  _InputField(
                    controller: phoneController,
                    label: loc.phone,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _required,
                  ),
                  BlocBuilder<DepartmentCubit, DepartmentState>(
                    builder: (context, state) {
                      if (state.loading && state.departments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (state.departments.isEmpty) {
                        return _WarningBox(message: loc.noDepartmentsHint);
                      }
                      return DropdownButtonFormField<int>(
                        value: selectedDep,
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
                        items: state.departments.map((department) {
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
                        onChanged: submitting
                            ? null
                            : (value) => setState(() { selectedDep = value; }),
                        validator: (value) {
                          if (value == null) return loc.selectDepartment;
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: roleIdController,
                    label: loc.role,
                    icon: Icons.verified_user_outlined,
                    keyboardType: TextInputType.number,
                    validator: _positiveNumber,
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: _isEditing ? loc.update : loc.add,
                    isLoading: submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton(
            onPressed: submitting ? null : () => Navigator.pop(context),
            child: Text(loc.cancel),
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

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String message;
  const _WarningBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          Icon(Icons.warning_amber_rounded, color: colors.error),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
