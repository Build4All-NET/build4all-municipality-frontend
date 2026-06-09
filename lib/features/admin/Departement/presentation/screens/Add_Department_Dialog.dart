import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDepartmentDialog extends StatefulWidget {
  final Department? department;

  const AddDepartmentDialog({
    super.key,
    this.department,
  });

  @override
  State<AddDepartmentDialog> createState() => _AddDepartmentDialogState();
}

class _AddDepartmentDialogState extends State<AddDepartmentDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  bool _submitting = false;

  bool get isEdit => widget.department != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.department?.name ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.department?.description ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';

    if (text.isEmpty) return loc.fieldRequired;

    return null;
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    final cubit = context.read<DepartmentCubit>();

    final department = Department(
      id: widget.department?.id ?? 0,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      isFixed: widget.department?.isFixed ?? false,
    );

    final ok = isEdit
        ? await cubit.update(department)
        : await cubit.add(department);

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    if (ok) {
      AppToast.show(
        context,
        message: isEdit ? loc.departmentUpdated : loc.departmentCreated,
        type: AppToastType.success,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Text(
        isEdit ? loc.editDepartment : loc.newDepartment,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                validator: _required,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: loc.name,
                  prefixIcon: const Icon(Icons.account_tree_outlined),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                validator: _required,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: loc.description,
                  prefixIcon: const Icon(Icons.description_outlined),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: isEdit ? loc.save : loc.add,
                isLoading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: Text(loc.cancel),
        ),
      ],
    );
  }
}