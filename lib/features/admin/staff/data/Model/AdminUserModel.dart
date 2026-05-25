class DepartmentSummary {
  final int id;
  final String name;

  const DepartmentSummary({required this.id, required this.name});

  factory DepartmentSummary.fromJson(Map<String, dynamic> json) {
    return DepartmentSummary(
      id: _toInt(json['id']),
      name: _asString(json['name']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _asString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }
}

class AdminUserModel {
  final int id;
  final int? ownerProjectLinkId;

  final String fullName;
  final String username;
  final String email;
  final String phone;

  final String roleName;
  final String status;
  final bool isVerified;
  final List<DepartmentSummary> assignedDepartments;

  const AdminUserModel({
    required this.id,
    this.ownerProjectLinkId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.roleName,
    required this.status,
    required this.isVerified,
    this.assignedDepartments = const [],
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    List<DepartmentSummary> parseDepartments(dynamic value) {
      if (value is! List) return [];
      return value
          .whereType<Map>()
          .map((e) => DepartmentSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return AdminUserModel(
      id: _toInt(json['id'] ?? json['userId'] ?? json['user_id']),
      ownerProjectLinkId: _toNullableInt(
        json['ownerProjectLinkId'] ?? json['owner_project_link_id'] ?? json['aupId'],
      ),
      fullName: _asString(json['fullName'] ?? json['full_name'] ?? json['name']),
      username: _asString(json['username'] ?? json['usernameField'] ?? json['username_field']),
      email: _asString(json['email']),
      phone: _asString(json['phone'] ?? json['phoneNumber'] ?? json['phone_number']),
      roleName: _asString(json['roleName'] ?? json['role_name'] ?? json['role']?['name']),
      status: _asString(json['status']),
      isVerified: _toBool(json['isVerified'] ?? json['verified'] ?? json['is_verified']),
      assignedDepartments: parseDepartments(
        json['assignedDepartments'] ?? json['assigned_departments'],
      ),
    );
  }

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (username.trim().isNotEmpty) return username.trim();
    if (email.trim().isNotEmpty) return email.trim();
    return '-';
  }

  String get departmentNames {
    if (assignedDepartments.isEmpty) return '-';
    return assignedDepartments.map((d) => d.name).join(', ');
  }

  static String _asString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }
}
