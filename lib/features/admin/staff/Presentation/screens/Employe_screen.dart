import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_State.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/screens/Add_Employe.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.employees)),

      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {

          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EmployeeLoaded) {
            return ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (_, i) {
                final emp = state.employees[i];

                return ListTile(
                  title: Text(emp.name),
                  subtitle: Text(emp.email),
                );
              },
            );
          }

          return Center(child: Text(loc.noData));
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final bloc = context.read<EmployeeBloc>();

          showDialog(
            context: context,
            builder: (_) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: bloc),
                ],
                child: const AddEmployeeDialog(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}