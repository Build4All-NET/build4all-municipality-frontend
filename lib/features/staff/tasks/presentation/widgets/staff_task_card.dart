import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class StaffTaskCard extends StatelessWidget {
  final StaffTaskModel task;
  final VoidCallback? onOpenForm;
  final VoidCallback? onAssign;
  final VoidCallback? onUnassign;

  const StaffTaskCard({
    super.key,
    required this.task,
    this.onOpenForm,
    this.onAssign,
    this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              title: task.name.isNotEmpty ? task.name : l10n.workflowTask,
            ),
            const SizedBox(height: 10),

            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: l10n.taskId,
              value: task.taskId.isEmpty ? '-' : task.taskId,
            ),

            if (task.state.isNotEmpty)
              _InfoRow(
                icon: Icons.flag_outlined,
                label: l10n.taskState,
                value: task.state,
              ),

            if (task.assignee.isNotEmpty)
              _InfoRow(
                icon: Icons.person_outline,
                label: l10n.taskAssignee,
                value: task.assignee,
              ),

            if (task.candidateUsers.isNotEmpty)
              _InfoRow(
                icon: Icons.group_outlined,
                label: l10n.taskCandidates,
                value: task.candidateUsers.join(', '),
              ),

            if (task.creationDate.isNotEmpty)
              _InfoRow(
                icon: Icons.schedule_outlined,
                label: l10n.taskCreated,
                value: task.creationDate,
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                if (task.canOpenForm)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onOpenForm,
                      icon: const Icon(Icons.dynamic_form_outlined),
                      label: Text(l10n.openForm),
                    ),
                  ),

                if (task.canOpenForm &&
                    (onAssign != null || onUnassign != null))
                  const SizedBox(width: 8),

                if (!task.isAssigned && onAssign != null)
                  OutlinedButton.icon(
                    onPressed: onAssign,
                    icon: const Icon(Icons.assignment_ind_outlined),
                    label: Text(l10n.assign),
                  ),

                if (task.isAssigned && onUnassign != null)
                  OutlinedButton.icon(
                    onPressed: onUnassign,
                    icon: const Icon(Icons.close),
                    label: Text(l10n.unassign),
                  ),
              ],
            ),

            if (task.isCompleted)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.completed,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          child: const Icon(Icons.task_alt_outlined),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: cs.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}