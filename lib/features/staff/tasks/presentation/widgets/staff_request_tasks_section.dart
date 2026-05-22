
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';
import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/features/staff/tasks/data/services/staff_task_api_service.dart';
import 'package:baladiyati/features/staff/tasks/presentation/widgets/staff_task_card.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class StaffRequestTasksSection extends StatefulWidget {
  final RequestEntity request;
  final StaffTaskApiService? apiService;
  final void Function(StaffTaskModel task)? onOpenTaskForm;

  const StaffRequestTasksSection({
    super.key,
    required this.request,
    this.apiService,
    this.onOpenTaskForm,
  });

  @override
  State<StaffRequestTasksSection> createState() =>
      _StaffRequestTasksSectionState();
}

class _StaffRequestTasksSectionState extends State<StaffRequestTasksSection> {
  bool _isLoading = false;
  bool _hasLoaded = false;
  List<StaffTaskModel> _tasks = [];

  Future<void> _loadTasks() async {
    final l10n = AppLocalizations.of(context)!;
    final processInstanceKey = widget.request.processInstanceKey;

    if (processInstanceKey == null || processInstanceKey <= 0) {
      AppToast.show(
        context,
        message: l10n.noWorkflowStarted,
        type: AppToastType.info,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final api = widget.apiService ?? StaffTaskApiService();

      final tasks = await api.getTasksByProcessInstanceKey(
        processInstanceKey,
      );

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
        _hasLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;

      AppToast.show(
        context,
        message: errorMessage(e),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final processInstanceKey = widget.request.processInstanceKey;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.workflowTasks,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            if (processInstanceKey == null || processInstanceKey <= 0)
              Text(
                l10n.noWorkflowStarted,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            else ...[
              PrimaryButton(
                label: l10n.loadTasks,
                isLoading: _isLoading,
                onPressed: _loadTasks,
              ),
              const SizedBox(height: 12),
              if (_hasLoaded && _tasks.isEmpty)
                Text(
                  l10n.noTasksFound,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              if (_tasks.isNotEmpty)
                Column(
                  children: _tasks
                      .map(
                        (task) => StaffTaskCard(
                          task: task,
                          onOpenForm: task.canOpenForm
                              ? () => widget.onOpenTaskForm?.call(task)
                              : null,
                        ),
                      )
                      .toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}