import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:baladiyati/features/staff/tasks/presentation/cubit/staff_tasks_cubit.dart';
import 'package:baladiyati/features/staff/tasks/presentation/cubit/staff_tasks_state.dart';
import 'package:baladiyati/features/staff/tasks/presentation/screens/staff_task_form_screen.dart';
import 'package:baladiyati/features/staff/tasks/presentation/widgets/staff_task_card.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class _StaffTasksBody extends StatelessWidget {
  const _StaffTasksBody();

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
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: state.tasks.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _TasksHeader(
                        count: state.tasks.length);
                  }
                  final task = state.tasks[index - 1];
                  return StaffTaskCard(
                    task: task,
                    onOpenForm: task.canOpenForm
                        ? () => _openTask(context, task)
                        : null,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  final int count;

  const _TasksHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  'Pending Tasks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$count task${count == 1 ? '' : 's'} waiting for your action',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$count',
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
