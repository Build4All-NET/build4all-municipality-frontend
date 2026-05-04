import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Role/Presenatation/cubit/role_cubit.dart';
import 'package:baladiyati/features/admin/Role/data/model/RoleModel.dart';
import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();

  int? selectedDep;
  int? selectedRole;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentCubit>().load();
      context.read<RoleCubit>().load();
    });
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.addEmployee),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: name,
              decoration: InputDecoration(labelText: loc.name),
            ),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: loc.email),
            ),

            TextField(
              controller: phone,
              decoration: InputDecoration(labelText: loc.phone),
            ),

            const SizedBox(height: 10),

            /// Department
            BlocBuilder<DepartmentCubit, List<DepartmentModel>>(
              builder: (context, deps) {
                    print("UI DEPS: $deps"); // 🔥 debug مهم

                return DropdownButtonFormField<int>(
                  hint: Text(loc.selectDepartment),
                  value: selectedDep,
                  items: deps.map((d) {
                    return DropdownMenuItem<int>(
                      value: d.id,
                      child: Text(d.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedDep = v;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 10),

            /// Role
            BlocBuilder<RoleCubit, List<RoleModel>>(
              builder: (context, roles) {
                return DropdownButtonFormField<int>(
                  hint: Text(loc.selectRole),
                  value: selectedRole,
                  items: roles.map((r) {
                    return DropdownMenuItem<int>(
                      value: r.id,
                      child: Text(r.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedRole = v;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),

      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.cancel),
        ),

        ElevatedButton(
          onPressed: () {
            if (name.text.isEmpty ||
                email.text.isEmpty ||
                phone.text.isEmpty ||
                selectedDep == null ||
                selectedRole == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please fill all fields")),
              );
              return;
            }

            final emp = Employee(
              name: name.text,
              email: email.text,
              phone: phone.text,
              depId: selectedDep!,
              roleId: selectedRole!,
            );

            context.read<EmployeeBloc>().add(AddEmployee(emp));
            Navigator.pop(context);
          },
          child: Text(loc.add),
        ),
      ],
    );
  }
}