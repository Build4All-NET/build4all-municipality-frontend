import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Bloc.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Event.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_State.dart';
import 'package:baladiyati/features/admin/Requests/presentation/screens/Request_Detail.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {

  @override
  void initState() {
    super.initState();

    context.read<RequestBloc>().add(LoadRequests());
    context.read<DepartmentCubit>().fetchDepartments();
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requests),
        centerTitle: true,
      ),

      body: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {

          final deptCubit = context.watch<DepartmentCubit>();

          return Column(
            children: [

              /// 🔍 SEARCH
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (val) {
                    context.read<RequestBloc>().add(SearchRequests(val));
                  },
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),

              /// 🔽 FILTERS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [

                    /// Department
                   Expanded(
  child: BlocBuilder<DepartmentCubit, DepartmentState>(
    builder: (context, depState) {
      return DropdownButtonFormField<int?>(
        value: state.selectedDepartmentId,
        decoration: InputDecoration(
          labelText: l10n.department,
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(l10n.all),
          ),

          ...depState.departments.map((d) {
            return DropdownMenuItem(
              value: d.id,
              child: Text(d.name),
            );
          }).toList(),
        ],
        onChanged: (val) {
          context.read<RequestBloc>().add(
            FilterRequests(
              departmentId: val,
              status: state.selectedStatus,
            ),
          );
        },
      );
    },
  ),
),

                    const SizedBox(width: 10),

                    /// Status
          Expanded(
  child: BlocBuilder<DepartmentCubit, DepartmentState>(
    builder: (context, depState) {

      /// loading
      if (depState.loading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      /// error
      if (depState.error != null) {
        return Text(depState.error!);
      }

      /// dropdown
      return DropdownButtonFormField<int?>(
        value: state.selectedDepartmentId,

        decoration: InputDecoration(
          labelText: l10n.department,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        items: [

          /// ALL
          DropdownMenuItem<int?>(
            value: null,
            child: Text(l10n.all),
          ),

          /// DB DATA
          ...depState.departments.map(
            (department) {
              return DropdownMenuItem<int?>(
                value: department.id,
                child: Text(department.name),
              );
            },
          ).toList(),
        ],

        onChanged: (value) {
          context.read<RequestBloc>().add(
            FilterRequests(
              departmentId: value,
              status: state.selectedStatus,
            ),
          );
        },
      );
    },
  ),
),
                
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 📋 LIST
              Expanded(
                child: state.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.visibleRequests.isEmpty
                        ? Center(child: Text(l10n.noData))
                        : ListView.builder(
                            itemCount: state.visibleRequests.length,
                            itemBuilder: (_, i) {
                              final r = state.visibleRequests[i];

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(
                                    r.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(r.addressText),

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RequestDetailPage(
                                          request: r,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}