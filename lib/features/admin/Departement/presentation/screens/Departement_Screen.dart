import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_bloc.dart';
import 'package:baladiyati/features/admin/Departement/presentation/screens/Add_Depart_screen.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DepartmentsPage extends StatelessWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: Text(t.departments),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // زر إضافة قسم
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1F3A5F),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddDepartmentDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(t.newDepartment),
              ),
            ),
          ),

          // القائمة
          Expanded(
            child: BlocBuilder<DepartmentBloc, DepartmentState>(
              builder: (context, state) {
                if (state is DepartmentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DepartmentLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.departments.length,
                    itemBuilder: (_, i) {
                      final dep = state.departments[i];
                      return DepartmentCard(department: dep);
                    },
                  );
                }

                if (state is DepartmentError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
class DepartmentCard extends StatelessWidget {
  final Department department;

  const DepartmentCard({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      department.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),

                    // حالة ثابت أو لا
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: department.isFixed
                            ? Colors.green
                            : const Color(0xff1F3A5F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        department.isFixed
                            ? t.fixed
                            : t.notFixed,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(department.description),

                const SizedBox(height: 10),

                Chip(
                  label: Text("${t.department}: ${department.name}"),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}