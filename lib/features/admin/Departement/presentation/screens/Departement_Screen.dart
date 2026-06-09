import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Departement/presentation/screens/Add_Department_Dialog.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDepartmentDialog(
    BuildContext context, {
    Department? department,
  }) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<DepartmentCubit>(),
        child: AddDepartmentDialog(department: department),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Department department,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.confirmDelete),
          content: Text(
            loc.deleteDepartmentConfirm(department.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(loc.cancel),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              icon: const Icon(Icons.delete_outline),
              label: Text(loc.delete),
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final ok = await context.read<DepartmentCubit>().delete(department.id);

    if (!context.mounted) return;

    if (ok) {
      AppToast.show(
        context,
        message: loc.departmentDeleted,
        type: AppToastType.success,
      );
    } else {
      final error = context.read<DepartmentCubit>().state.error;
      if (error != null && error.isNotEmpty) {
        AppToast.show(context, message: error, type: AppToastType.error);
      } else {
        AppToast.show(context, message: loc.deleteFailed, type: AppToastType.error);
      }
    }
  }

  Future<void> _refresh(BuildContext context) async {
    await context.read<DepartmentCubit>().fetchDepartments();
  }

  void _clearSearch(BuildContext context) {
    _searchController.clear();
    context.read<DepartmentCubit>().clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<DepartmentCubit, DepartmentState>(
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
        final cubit = context.read<DepartmentCubit>();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(loc.departments),
            actions: [
              IconButton(
                tooltip: loc.update,
                icon: const Icon(Icons.refresh),
                onPressed: state.loading ? null : cubit.fetchDepartments,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.actionLoading || state.loading
                ? null
                : () => _openDepartmentDialog(context),
            icon: const Icon(Icons.add),
            label: Text(loc.add),
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _HeaderCard(
                  title: loc.departments,
                  subtitle: loc.manageDepartments,
                  count: state.departments.length,
                ),

                const SizedBox(height: 16),

                AppSearchField(
                  controller: _searchController,
                  hint: loc.search,
                  onChanged: cubit.searchDepartments,
                  onClear: _searchController.text.trim().isEmpty
                      ? null
                      : () => _clearSearch(context),
                ),

                const SizedBox(height: 12),

                _FilterCard(
                  selectedId: state.selectedId,
                  departments: state.departments,
                  onChanged: cubit.filterByDepartment,
                ),

                const SizedBox(height: 12),

                _ResultSummary(
                  shown: state.filtered.length,
                  total: state.departments.length,
                  hasSearch: state.searchQuery.trim().isNotEmpty,
                  hasFilter: state.selectedId != null,
                ),

                const SizedBox(height: 16),

                if (state.loading && state.departments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.filtered.isEmpty)
                  _EmptyState(
                    title: loc.noData,
                    subtitle: loc.noDepartmentsHint,
                  )
                else
                  ...state.filtered.map(
                    (dep) => _DepartmentCard(
                      department: dep,
                      isBusy: state.actionLoading,
                      onEdit: () => _openDepartmentDialog(
                        context,
                        department: dep,
                      ),
                      onDelete: dep.isFixed
                          ? null
                          : () => _confirmDelete(context, dep),
                    ),
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
              Icons.account_tree_outlined,
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

class _FilterCard extends StatelessWidget {
  final int? selectedId;
  final List<Department> departments;
  final ValueChanged<int?> onChanged;

  const _FilterCard({
    required this.selectedId,
    required this.departments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withOpacity(0.14),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedId,
          isExpanded: true,
          hint: Text(loc.allDepartments),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(loc.all),
            ),
            ...departments.map(
              (d) => DropdownMenuItem<int?>(
                value: d.id,
                child: Text(d.name),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  final int shown;
  final int total;
  final bool hasSearch;
  final bool hasFilter;

  const _ResultSummary({
    required this.shown,
    required this.total,
    required this.hasSearch,
    required this.hasFilter,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_outlined,
            color: colors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$shown / $total',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasSearch || hasFilter)
            Text(
              loc.filtered,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final Department department;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _DepartmentCard({
    required this.department,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: colors.primary.withOpacity(0.12),
          child: Icon(
            Icons.account_tree_outlined,
            color: colors.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                department.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (department.isFixed)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  loc.fixed,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            department.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.68),
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          enabled: !isBusy,
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            }

            if (value == 'delete' && onDelete != null) {
              onDelete!();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined),
                  const SizedBox(width: 8),
                  Text(loc.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              enabled: onDelete != null,
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: onDelete == null ? colors.outline : colors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.delete,
                    style: TextStyle(
                      color: onDelete == null ? colors.outline : colors.error,
                    ),
                  ),
                ],
              ),
            ),
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
            Icons.account_tree_outlined,
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