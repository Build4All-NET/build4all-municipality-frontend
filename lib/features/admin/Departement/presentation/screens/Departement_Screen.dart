import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/Entities/Departement.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<DepartmentCubit, DepartmentState>(
      builder: (context, state) {
        final cubit = context.read<DepartmentCubit>();

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.departments),
          ),

          body: Column(
            children: [

              // 🔽 DROPDOWN FILTER
              DropdownButton<int?>(
                value: state.selectedId,
                hint: Text(loc.allDepartments),

                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(loc.all), // "الكل"
                  ),

                  ...state.departments.map((d) {
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text(d.name),
                    );
                  }).toList(),
                ],

                onChanged: (value) {
                  cubit.filterByDepartment(value);
                },
              ),

              // 📋 LIST
              Expanded(
                child: state.loading
                    ? Center(child: CircularProgressIndicator())
                    : state.filtered.isEmpty
                        ? Center(child: Text(loc.noData))
                        : ListView.builder(
                            itemCount: state.filtered.length,
                            itemBuilder: (context, i) {
                              final dep = state.filtered[i];

                              return ListTile(
                                title: Text(dep.name),
                                subtitle: Text(dep.description),

                                trailing: PopupMenuButton(
                                  onSelected: (value) {
                                    if (value == "delete") {
                                      cubit.delete(dep.id);
                                    }
                                  },

                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: "delete",
                                      child: Text(loc.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // open add dialog
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}