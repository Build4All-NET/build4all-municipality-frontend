import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_State.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:baladiyati/features/admin/staff/Presentation/screens/Add_Employe.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddEmployeeDialog() async {
    final employeeBloc = context.read<EmployeeBloc>();
    final departmentCubit = context.read<DepartmentCubit>();

    await showDialog(
      context: context,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: employeeBloc),
            BlocProvider.value(value: departmentCubit),
          ],
          child: const AddEmployeeDialog(),
        );
      },
    );
  }

  Future<void> _refresh() async {
    context.read<EmployeeBloc>().add(LoadEmployees());
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<EmployeeBloc>().add(SearchEmployees(''));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<EmployeeBloc, EmployeeState>(
      listener: (context, state) {
        final error = state.error;

        if (error != null && error.isNotEmpty) {
          AppToast.show(
            context,
            message: error,
            type: AppToastType.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(loc.employees),
            actions: [
              IconButton(
                tooltip: loc.update,
                icon: const Icon(Icons.refresh),
                onPressed: state.loading || state.actionLoading
                    ? null
                    : () => context.read<EmployeeBloc>().add(LoadEmployees()),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.loading || state.actionLoading
                ? null
                : _openAddEmployeeDialog,
            icon: const Icon(Icons.add),
            label: Text(loc.add),
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _HeaderCard(
                  title: loc.employees,
                  subtitle: loc.manageEmployees,
                  count: state.allEmployees.length,
                ),
                const SizedBox(height: 16),
                AppSearchField(
                  controller: _searchController,
                  hint: loc.search,
                  onChanged: (value) {
                    context.read<EmployeeBloc>().add(SearchEmployees(value));
                    setState(() {});
                  },
                  onClear: _searchController.text.trim().isEmpty
                      ? null
                      : _clearSearch,
                ),
                const SizedBox(height: 16),
                if (state.loading && state.allEmployees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.visibleEmployees.isEmpty)
                  _EmptyState(
                    title: loc.noData,
                    subtitle: loc.noEmployeesHint,
                  )
                else
                  ...state.visibleEmployees.map(
                    (employee) => _EmployeeCard(employee: employee),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;

  const _EmployeeCard({
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colors.primary.withOpacity(0.12),
          child: Icon(Icons.person_outline, color: colors.primary),
        ),
        title: Text(
          employee.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${employee.email}\n${loc.phone}: ${employee.phone}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.68),
            ),
          ),
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${loc.department}: ${employee.depId}'),
            const SizedBox(height: 4),
            Text('${loc.role}: ${employee.roleId}'),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          Icon(
            Icons.badge_outlined,
            size: 58,
            color: colors.onSurface.withOpacity(0.35),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}