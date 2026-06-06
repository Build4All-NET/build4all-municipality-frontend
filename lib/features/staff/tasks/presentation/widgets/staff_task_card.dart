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
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpenForm,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? colors.surfaceVariant
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      task.isCompleted
                          ? Icons.check_circle_outline
                          : Icons.assignment_outlined,
                      size: 20,
                      color: task.isCompleted
                          ? colors.onSurfaceVariant
                          : colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name.isNotEmpty
                              ? task.name
                              : l10n.workflowTask,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        if (task.creationDate.isNotEmpty) ...
                          [
                            const SizedBox(height: 2),
                            Text(
                              task.creationDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(state: task.state),
                ],
              ),
              if (task.departmentLabels.isNotEmpty) ...
                [
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: task.departmentLabels.map((label) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              if (!task.isCompleted &&
                  (task.canOpenForm ||
                      onAssign != null ||
                      onUnassign != null)) ...
                [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (task.canOpenForm)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onOpenForm,
                            icon: const Icon(Icons.edit_document, size: 17),
                            label: Text(l10n.openForm),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                            ),
                          ),
                        ),
                      if (task.canOpenForm &&
                          (onAssign != null || onUnassign != null))
                        const SizedBox(width: 8),
                      if (!task.isAssigned && onAssign != null)
                        OutlinedButton.icon(
                          onPressed: onAssign,
                          icon: const Icon(Icons.person_add_outlined,
                              size: 17),
                          label: Text(l10n.assign),
                        ),
                      if (task.isAssigned && onUnassign != null)
                        OutlinedButton.icon(
                          onPressed: onUnassign,
                          icon: const Icon(Icons.person_remove_outlined,
                              size: 17),
                          label: Text(l10n.unassign),
                        ),
                    ],
                  ),
                ],
              if (task.isCompleted) ...
                [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16,
                          color: colors.primary.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        l10n.completed,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.primary.withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String state;

  const _StatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final upper = state.toUpperCase();

    final Color bg;
    final Color fg;
    final String label;

    if (upper == 'COMPLETED' || upper == 'DONE') {
      bg = colors.surfaceVariant;
      fg = colors.onSurfaceVariant;
      label = 'Done';
    } else if (upper == 'CREATED' || upper == 'PENDING') {
      bg = colors.primaryContainer;
      fg = colors.onPrimaryContainer;
      label = 'Pending';
    } else if (upper == 'ASSIGNED') {
      bg = colors.tertiaryContainer;
      fg = colors.onTertiaryContainer;
      label = 'Assigned';
    } else {
      bg = colors.surfaceVariant;
      fg = colors.onSurfaceVariant;
      label = state.isEmpty ? '-' : state;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
