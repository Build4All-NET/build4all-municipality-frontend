class StaffTaskModel {
  final int? id;
  final String taskId;
  final String name;
  final String state;
  final String assignee;
  final List<String> candidateUsers;
  final String creationDate;
  final String completionDate;
  final int? processInstanceKey;

  const StaffTaskModel({
    required this.id,
    required this.taskId,
    required this.name,
    required this.state,
    required this.assignee,
    required this.candidateUsers,
    required this.creationDate,
    required this.completionDate,
    required this.processInstanceKey,
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

    final rawId = json['id'] ??
        json['taskId'] ??
        json['task_id'] ??
        json['key'];

    return StaffTaskModel(
      id: asNullableInt(rawId),
      taskId: asString(rawId),
      name: asString(
        json['name'] ??
            json['taskName'] ??
            json['task_name'] ??
            json['elementId'],
      ),
      state: asString(
        json['state'] ??
            json['status'] ??
            json['taskState'],
      ),
      assignee: asString(json['assignee']),
      candidateUsers: asStringList(
        json['candidateUsers'] ??
            json['candidate_users'] ??
            json['candidateGroups'],
      ),
      creationDate: asString(
        json['creationDate'] ??
            json['createdAt'] ??
            json['created_at'],
      ),
      completionDate: asString(
        json['completionDate'] ??
            json['completedAt'] ??
            json['completed_at'],
      ),
      processInstanceKey: asNullableInt(
        json['processInstanceKey'] ?? json['process_instance_key'],
      ),
    );
  }

  bool get isAssigned => assignee.isNotEmpty;

  bool get isCompleted {
    final value = state.toUpperCase();
    return value == 'COMPLETED' || value == 'DONE';
  }

  bool get canOpenForm => id != null && !isCompleted;
}