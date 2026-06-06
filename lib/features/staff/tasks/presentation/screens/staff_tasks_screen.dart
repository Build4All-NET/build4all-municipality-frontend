import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:baladiyati/features/staff/tasks/presentation/cubit/staff_tasks_cubit.dart';
import 'package:baladiyati/features/staff/tasks/presentation/cubit/staff_tasks_state.dart';
import 'package:baladiyati/features/staff/tasks/presentation/screens/staff_task_form_screen.dart';
import 'package:baladiyati/features/staff/tasks/presentation/widgets/staff_task_card.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _TaskFilter { all, active, done }

class StaffTasksScreen extends StatelessWidget {
  const StaffTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffTasksCubit(StaffTaskApiService())..loadTasks(),
      child: const _StaffTasksBody(),
    );
  }
}

class _StaffTasksBody extends StatefulWidget {
  const _StaffTasksBody();

  @override
  State<_StaffTasksBody> createState() => _StaffTasksBodyState();
}

class _StaffTasksBodyState extends State<_StaffTasksBody> {
  _TaskFilter _filter = _TaskFilter.all;

  Future<void> _openTask(BuildContext context, StaffTaskModel task) async {
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StaffTaskFormScreen(task: task),
      ),
    );
    if (refreshed == true && context.mounted) {
      context.read<StaffTasksCubit>().loadTasks();
    }
  }

  List<StaffTaskModel> _applyFilter(List<StaffTaskModel> tasks) {
    return switch (_filter) {
      _TaskFilter.all => tasks,
      _TaskFilter.active => tasks.where((t) => !t.isCompleted).toList(),
      _TaskFilter.done => tasks.where((t) => t.isCompleted).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.workflowTasks,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          BlocBuilder<StaffTasksCubit, StaffTasksState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: state is StaffTasksLoading
                    ? null
                    : () => context.read<StaffTasksCubit>().loadTasks(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StaffTasksCubit, StaffTasksState>(
        builder: (context, state) {
          if (state is StaffTasksInitial || state is StaffTasksLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 14),
                  Text(
                    'Loading your tasks...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is StaffTasksError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 40,
                        color: colors.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Failed to load tasks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<StaffTasksCubit>().loadTasks(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is StaffTasksLoaded) {
            final filtered = _applyFilter(state.tasks);
            final activeCount =
                state.tasks.where((t) => !t.isCompleted).length;
            final doneCount = state.tasks.where((t) => t.isCompleted).length;

            if (state.tasks.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<StaffTasksCubit>().loadTasks(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(28),
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inbox_outlined,
                              size: 52,
                              color: colors.primary.withOpacity(0.65),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'No tasks available',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'There are no pending tasks for your assigned departments.\n\nIf you believe you should have access to tasks, contact your administrator to verify your department assignments.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 22),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.read<StaffTasksCubit>().loadTasks(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Check again'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<StaffTasksCubit>().loadTasks(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _TasksHeader(
                        total: state.tasks.length,
                        activeCount: activeCount,
                        doneCount: doneCount,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: _FilterChips(
                        selected: _filter,
                        activeCount: activeCount,
                        doneCount: doneCount,
                        totalCount: state.tasks.length,
                        onChanged: (f) => setState(() => _filter = f),
                        l10n: l10n,
                        colors: colors,
                        theme: theme,
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 48,
                                color: colors.primary.withOpacity(0.4)),
                            const SizedBox(height: 14),
                            Text(
                              _filter == _TaskFilter.active
                                  ? 'No active tasks'
                                  : 'No completed tasks',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = filtered[index];
                            return StaffTaskCard(
                              task: task,
                              onOpenForm: () => _openTask(context, task),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
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

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final _TaskFilter selected;
  final int totalCount;
  final int activeCount;
  final int doneCount;
  final void Function(_TaskFilter) onChanged;
  final AppLocalizations l10n;
  final ColorScheme colors;
  final ThemeData theme;

  const _FilterChips({
    required this.selected,
    required this.totalCount,
    required this.activeCount,
    required this.doneCount,
    required this.onChanged,
    required this.l10n,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: l10n.filterAll,
            count: totalCount,
            selected: selected == _TaskFilter.all,
            onTap: () => onChanged(_TaskFilter.all),
            colors: colors,
            theme: theme,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.filterActive,
            count: activeCount,
            selected: selected == _TaskFilter.active,
            onTap: () => onChanged(_TaskFilter.active),
            colors: colors,
            theme: theme,
            selectedColor: colors.tertiary,
            selectedOnColor: colors.onTertiary,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.filterDone,
            count: doneCount,
            selected: selected == _TaskFilter.done,
            onTap: () => onChanged(_TaskFilter.done),
            colors: colors,
            theme: theme,
            selectedColor: colors.surfaceVariant,
            selectedOnColor: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colors;
  final ThemeData theme;
  final Color? selectedColor;
  final Color? selectedOnColor;

  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.theme,
    this.selectedColor,
    this.selectedOnColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (selectedColor ?? colors.primary)
        : colors.surfaceVariant.withOpacity(0.6);
    final fg = selected
        ? (selectedOnColor ?? colors.onPrimary)
        : colors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : colors.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? fg.withOpacity(0.18)
                    : colors.outline.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tasks header card ────────────────────────────────────────────────────────

class _TasksHeader extends StatelessWidget {
  final int total;
  final int activeCount;
  final int doneCount;

  const _TasksHeader({
    required this.total,
    required this.activeCount,
    required this.doneCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.task_alt_outlined, color: colors.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tasks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$activeCount active · $doneCount done',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$total',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
