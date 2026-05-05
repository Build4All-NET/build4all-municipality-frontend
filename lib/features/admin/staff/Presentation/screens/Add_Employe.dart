import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Role/Presenatation/cubit/role_cubit.dart';
import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Role/Presenatation/cubit/Role_state.dart';

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  int? selectedDep;
  int? selectedRole;

  @override
  void initState() {
    super.initState();

    // تحميل البيانات
    Future.microtask(() {
      context.read<DepartmentCubit>().fetchDepartments();
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
    final empBloc = context.read<EmployeeBloc>();

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

            /// Department Dropdown
            BlocBuilder<DepartmentCubit, DepartmentState>(
              builder: (context, state) {
                if (state.loading) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<int>(
                  hint: Text(loc.selectDepartment),
                  value: selectedDep,
                  items: state.departments.map((d) {
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text(d.name),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedDep = v),
                );
              },
            ),

            const SizedBox(height: 10),

            /// Role Dropdown
            BlocBuilder<RoleCubit, RoleState>(
              builder: (context, state) {
                if (state.loading) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<int>(
                  hint: Text(loc.selectRole),
                  value: selectedRole,
                  items: state.roles.map((r) {
                    return DropdownMenuItem(
                      value: r.id,
                      child: Text(r.name),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedRole = v),
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
            /// ✅ حماية من crash
            if (name.text.isEmpty ||
                email.text.isEmpty ||
                phone.text.isEmpty ||
                selectedDep == null ||
                selectedRole == null) {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fill all fields")),
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

            empBloc.add(AddEmployee(emp));

            Navigator.pop(context);
          },
          child: Text(loc.add),
        ),
      ],
    );
  }
}