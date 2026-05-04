import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Role/Presenatation/cubit/role_cubit.dart';
import 'package:baladiyati/features/admin/Role/data/service/Role_Api_Service.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_State.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/screens/Add_Employe.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
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

          } else if (state is EmployeeLoaded) {
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

          } else {
            return Center(child: Text(loc.noData));
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /// ✅ نحفظ الـ bloc قبل ما نفتح dialog (حل المشكلة)
          final employeeBloc = context.read<EmployeeBloc>();

          showDialog(
            context: context,
            builder: (_) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) =>
                        DepartmentCubit(DepartmentApiService(Dio()))..load(),
                  ),
                  BlocProvider(
                    create: (_) =>
                        RoleCubit(RoleApiService(DioClient.muni))..load(),
                  ),
                  BlocProvider.value(
                    value: employeeBloc,
                  ),
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