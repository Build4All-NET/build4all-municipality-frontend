import 'package:baladiyati/features/admin/violations/data/repository/violation_repository_impl.dart';

import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/AddViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/Getviolation.dart';

import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_bloc.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/AddViolationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class ViolationsPage extends StatelessWidget {
  const ViolationsPage({super.key});

   @override
  Widget build(BuildContext context) {
    final repo = ViolationRepositoryImpl(ViolationApiService());

    return BlocProvider(
      create: (_) => ViolationBloc(
        AddViolation(repo),
        GetViolations(repo),
      )..add(LoadViolationsEvent()),
      child: const ViolationsBody(),
    );
  }
}

class ViolationsBody extends StatefulWidget {
  const ViolationsBody({super.key});

  @override
  State<ViolationsBody> createState() => _ViolationsBodyState();
}

class _ViolationsBodyState extends State<ViolationsBody> {
  String selectedDepartment = "all";

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.violations),
        backgroundColor: const Color(0xFF2F5DA9),

        /// ➕ ADD BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final bloc = context.read<ViolationBloc>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc, // 👈 reuse same bloc
                    child: const CreateViolationScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔍 SEARCH + FILTER
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: loc.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedDepartment,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: "all", child: Text(loc.all)),
                      DropdownMenuItem(value: "eng", child: Text(loc.engineering)),
                      DropdownMenuItem(value: "finance", child: Text(loc.finance)),
                      DropdownMenuItem(value: "police", child: Text(loc.police)),
                    ],
                    onChanged: (val) => setState(() => selectedDepartment = val!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 📋 LIST FROM API
            Expanded(
              child: BlocBuilder<ViolationBloc, ViolationState>(
                builder: (context, state) {

                  /// 🔄 LOADING
                  if (state is ViolationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  /// ❌ ERROR
                  if (state is ViolationError) {
                    return Center(child: Text(state.message));
                  }

                  /// ✅ DATA
                  if (state is ViolationLoaded) {
                    final list = state.violations;

                    if (list.isEmpty) {
                      return const Center(child: Text("No violations"));
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final v = list[index];

                        return _violationCard(
                          v.title,
                          "${v.amount} \$",
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _violationCard(String title, String price) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(price),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}