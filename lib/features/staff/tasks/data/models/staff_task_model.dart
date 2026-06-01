class StaffTaskModel {
  final int? id;
  final String taskId;
  final String name;
  final String description;
  final String state;
  final String assignee;
  final List<String> candidateUsers;
  final List<String> candidateGroups;
  final String creationDate;
  final String completionDate;
  final int? processInstanceKey;
  final int? rootProcessInstanceKey;
  final Map<String, dynamic> variables;

  const StaffTaskModel({
    required this.id,
    required this.taskId,
    required this.name,
    this.description = '',
    required this.state,
    required this.assignee,
    required this.candidateUsers,
    this.candidateGroups = const [],
    required this.creationDate,
    required this.completionDate,
    required this.processInstanceKey,
    this.rootProcessInstanceKey,
    this.variables = const {},
  });

  factory StaffTaskModel.fromJson(Map<String, dynamic> json) {
    int? asNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    String asString(dynamic value) {
      final text = value?.toString().trim() ?? '';
      return text.toLowerCase() == 'null' ? '' : text;
    }

    List<String> asStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        return [value.trim()];
      }
      return [];
    }

    Map<String, dynamic> asVariables(dynamic value) {
      if (value is Map) return Map<String, dynamic>.from(value);
      if (value is List) {
        final result = <String, dynamic>{};
        for (final item in value) {
          if (item is Map) {
            final name = item['name']?.toString() ?? item['key']?.toString();
            final val = item['value'];
            if (name != null) result[name] = val;
          }
        }
        return result;
      }
      return {};
    }

    // Camunda v2 returns the task key as 'userTaskKey'
    final rawId = json['userTaskKey'] ??
        json['id'] ??
        json['taskId'] ??
        json['task_id'] ??
        json['key'];

    return StaffTaskModel(
      id: asNullableInt(rawId),
      taskId: asString(rawId),
      name: asString(
        json['name'] ?? json['taskName'] ?? json['task_name'] ?? json['elementId'],
      ),
      description: asString(json['description'] ?? json['taskDescription']),
      state: asString(json['state'] ?? json['taskState'] ?? json['status']),
      assignee: asString(json['assignee']),
      candidateUsers: asStringList(
        json['candidateUsers'] ?? json['candidate_users'],
      ),
      candidateGroups: asStringList(
        json['candidateGroups'] ?? json['candidate_groups'],
      ),
      creationDate: asString(
        json['creationDate'] ?? json['createdAt'] ?? json['created_at'],
      ),
      completionDate: asString(
        json['completionDate'] ?? json['completedAt'] ?? json['completed_at'],
      ),
      processInstanceKey: asNullableInt(
        json['processInstanceKey'] ?? json['process_instance_key'],
      ),
      rootProcessInstanceKey: asNullableInt(
        json['rootProcessInstanceKey'] ?? json['root_process_instance_key'],
      ),
      variables: asVariables(json['variables']),
    );
  }

  /// The key to use when looking up the certificate.
  /// Camunda stores the root key in Request, so prefer rootProcessInstanceKey.
  int? get certificateLookupKey => rootProcessInstanceKey ?? processInstanceKey;

  bool get isAssigned => assignee.isNotEmpty;

  bool get isCompleted {
    final value = state.toUpperCase();
    return value == 'COMPLETED' || value == 'DONE' ||
        value == 'CANCELED' || value == 'FAILED';
  }

  bool get canOpenForm => id != null && !isCompleted;

  List<String> get departmentLabels {
    return candidateGroups
        .where((g) => g.startsWith('DEP_'))
        .map((g) {
          final raw = g.replaceFirst('DEP_', '').replaceAll('_', ' ');
          return raw
              .toLowerCase()
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
              .join(' ');
        })
        .toList();
  }
}
