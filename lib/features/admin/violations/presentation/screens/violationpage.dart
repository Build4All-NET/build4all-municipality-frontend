import 'package:baladiyati/features/admin/violations/data/repository/violation_repository_impl.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/AddViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/DeleteViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/Getviolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/UpdateViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_bloc.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/AddViolationPage.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViolationsPage extends StatelessWidget {
  const ViolationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ViolationRepositoryImpl(ViolationApiService());

    return BlocProvider(
      create: (_) => ViolationBloc(
        addViolation: AddViolation(repo),
        getViolations: GetViolations(repo),
        updateViolation: UpdateViolation(repo),
        deleteViolation: DeleteViolation(repo),
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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Violation> _filter(List<Violation> list) {
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return list;

    return list.where((v) {
      return v.title.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q) ||
          v.citizenName.toLowerCase().contains(q) ||
          v.location.toLowerCase().contains(q) ||
          (v.departmentName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.violations),
        backgroundColor: const Color(0xFF2F5DA9),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ViolationBloc>().add(LoadViolationsEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final bloc = context.read<ViolationBloc>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const CreateViolationScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ViolationBloc, ViolationState>(
        builder: (context, state) {
          if (state is ViolationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ViolationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state is ViolationLoaded) {
            final filtered = _filter(state.violations);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ViolationBloc>().add(LoadViolationsEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _query = value);
                    },
                    decoration: InputDecoration(
                      hintText: loc.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: Text('No violations found')),
                    )
                  else
                    ...filtered.map(
                      (v) => _ViolationCard(violation: v),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ViolationCard extends StatelessWidget {
  final Violation violation;

  const _ViolationCard({
    required this.violation,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ViolationBloc>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(
          violation.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${violation.amount.toStringAsFixed(2)} \$ • ${violation.citizenName}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          _row('Description', violation.description),
          _row('Location', violation.location),
          _row('Date', violation.violationDate),
          _row('Department', violation.departmentName ?? '${violation.departmentId}'),
          if (violation.municipalityName != null)
            _row('Municipality', violation.municipalityName!),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: CreateViolationScreen(
                            violation: violation,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: violation.id == null
                      ? null
                      : () => _confirmDelete(context, violation.id!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete violation'),
          content: const Text('Are you sure you want to delete this violation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                context.read<ViolationBloc>().add(DeleteViolationEvent(id));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}