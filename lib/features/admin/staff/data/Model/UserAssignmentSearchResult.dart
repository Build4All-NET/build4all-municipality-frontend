class UserAssignmentSearchResult {
  final bool exists;
  final bool alreadyAssigned;
  final bool isOwnerAccount;

  final int? userId;
  final int? ownerProjectLinkId;

  final String fullName;
  final String email;
  final String phone;
  final String username;

  final String currentRoleName;
  final String targetRoleName;
  final String status;
  final bool isVerified;

  const UserAssignmentSearchResult({
    required this.exists,
    required this.alreadyAssigned,
    required this.isOwnerAccount,
    this.userId,
    this.ownerProjectLinkId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.username,
    required this.currentRoleName,
    required this.targetRoleName,
    required this.status,
    required this.isVerified,
  });

  factory UserAssignmentSearchResult.fromJson(Map<String, dynamic> json) {
    return UserAssignmentSearchResult(
      exists: _toBool(json['exists']),
      alreadyAssigned: _toBool(json['alreadyAssigned'] ?? json['already_assigned']),
      isOwnerAccount: _toBool(json['isOwnerAccount'] ?? json['is_owner_account']),
      userId: _toNullableInt(json['userId'] ?? json['user_id']),
      ownerProjectLinkId: _toNullableInt(
        json['ownerProjectLinkId'] ??
            json['owner_project_link_id'] ??
            json['aupId'],
      ),
      fullName: _asString(json['fullName'] ?? json['full_name'] ?? json['name']),
      email: _asString(json['email']),
      phone: _asString(json['phone'] ?? json['phoneNumber'] ?? json['phone_number']),
      username: _asString(
        json['username'] ??
            json['usernameField'] ??
            json['username_field'],
      ),
      currentRoleName: _asString(
        json['currentRoleName'] ??
            json['current_role_name'],
      ),
      targetRoleName: _asString(
        json['targetRoleName'] ??
            json['target_role_name'],
      ),
      status: _asString(json['status']),
      isVerified: _toBool(
        json['isVerified'] ??
            json['verified'] ??
            json['is_verified'],
      ),
    );
  }

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (username.trim().isNotEmpty) return username.trim();
    if (email.trim().isNotEmpty) return email.trim();
    return '-';
  }

  static String _asString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
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
