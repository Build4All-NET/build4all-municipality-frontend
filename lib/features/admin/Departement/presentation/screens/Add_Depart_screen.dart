import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_Event.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AddDepartmentDialog extends StatefulWidget {
  const AddDepartmentDialog({super.key});

  @override
  State<AddDepartmentDialog> createState() =>
      _AddDepartmentDialogState();
}

class _AddDepartmentDialogState
    extends State<AddDepartmentDialog> {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  bool isFixed = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                t.addDepartment,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              _buildField(t.departmentName, nameController),
              _buildField(t.description, descController),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: isFixed,
                    onChanged: (val) {
                      setState(() => isFixed = val ?? false);
                    },
                  ),
                  Text(t.isFixed),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1F3A5F),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final department = Department(
                      id: 0,
                      name: nameController.text,
                      description: descController.text,
                      isFixed: isFixed,
                    );

                    context.read<DepartmentBloc>().add(
                          CreateDepartmentEvent(department),
                        );

                    Navigator.pop(context);
                  },
                  child: Text(t.addDepartmentButton),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}