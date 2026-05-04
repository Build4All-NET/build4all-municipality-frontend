import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Departement/presentation/screens/Add_Depart_screen.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => DepartmentCubit(
        DepartmentApiService(DioClient.muni)
      )..load(), // ✅ هون مكانها الصحيح

      child: Scaffold(
        appBar: AppBar(title: Text(loc.departments)),

        body: BlocBuilder<DepartmentCubit, List<DepartmentModel>>(
          builder: (context, state) {
            if (state.isEmpty) {
              return Center(child: Text(loc.noData));
            }

            return ListView.builder(
              itemCount: state.length,
              itemBuilder: (_, i) {
                final dep = state[i];

                return ListTile(
                  title: Text(dep.name),
                  subtitle: Text(dep.description),

                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      final cubit = context.read<DepartmentCubit>();

                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return BlocProvider.value(
                              value: cubit,
                              child: AddDepartmentDialog(
                                department: dep,
                              ),
                            );
                          },
                        );
                      }

                      if (value == 'delete') {
                        cubit.delete(dep.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text("Edit")),
                      PopupMenuItem(value: 'delete', child: Text("Delete")),
                    ],
                  ),
                );
              },
            );
          },
        ),

        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return BlocProvider.value(
                      value: context.read<DepartmentCubit>(),
                      child: const AddDepartmentDialog(),
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}