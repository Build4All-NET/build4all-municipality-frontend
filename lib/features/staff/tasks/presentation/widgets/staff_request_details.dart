import 'package:baladiyati/features/staff/tasks/data/models/staff_task_model.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Ordered label/value pairs describing the citizen request behind a staff
/// task, built from the fields the backend enriches onto [StaffTaskModel].
/// Shared between the compact list-card section and the task-form screen so
/// both surfaces stay in sync.
List<MapEntry<String, String>> buildRequestDetailEntries(
  BuildContext context,
  StaffTaskModel task,
) {
  final l10n = AppLocalizations.of(context)!;

  String orDash(String value) => value.isEmpty ? '-' : value;

  final department = task.department.isNotEmpty
      ? task.department
      : task.departmentLabels.join(', ');
  final status = task.requestStatus.isNotEmpty ? task.requestStatus : task.state;

  return [
    MapEntry(l10n.requestId, task.requestId?.toString() ?? '-'),
    MapEntry(l10n.requestTitle, orDash(task.requestName)),
    MapEntry(l10n.citizenName, orDash(task.requesterName)),
    MapEntry(l10n.service, orDash(task.serviceType)),
    MapEntry(l10n.department, orDash(department)),
    MapEntry(l10n.status, orDash(status)),
    MapEntry(l10n.tracking, orDash(task.trackingNumber)),
    MapEntry(l10n.taskType, orDash(task.displayName)),
    MapEntry(l10n.created, orDash(task.creationDate)),
  ];
}
