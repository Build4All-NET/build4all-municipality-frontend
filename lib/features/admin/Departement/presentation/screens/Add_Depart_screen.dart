import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDepartmentDialog extends StatefulWidget {
  final DepartmentModel? department;

  const AddDepartmentDialog({super.key, this.department});

  @override
  State<AddDepartmentDialog> createState() => _AddDepartmentDialogState();
}

class _AddDepartmentDialogState extends State<AddDepartmentDialog> {
  final name = TextEditingController();
  final description = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.department != null) {
      name.text = widget.department!.name;
      description.text = widget.department!.description;
    }
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        widget.department == null ? loc.newDepartment : loc.edit,
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            controller: name,
            decoration: InputDecoration(
              labelText: loc.name,
            ),
          ),

          TextField(
            controller: description,
            decoration: InputDecoration(
              labelText: loc.description,
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.cancel),
        ),

        ElevatedButton(
          onPressed: () {
            if (name.text.isEmpty || description.text.isEmpty) return;

            final model = DepartmentModel(
              id: widget.department?.id ??
                  DateTime.now().millisecondsSinceEpoch,
              name: name.text,
              description: description.text,
              isFixed: widget.department?.isFixed ?? false,
            );

            final cubit = context.read<DepartmentCubit>();

            if (widget.department == null) {
              cubit.add(model);
            } else {
              cubit.update(model);
            }

            Navigator.pop(context);
          },
          child: Text(
            widget.department == null ? loc.add : loc.edit,
          ),
        ),
      ],
    );
  }
}