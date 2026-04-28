class AdminLoginResponse {
  final String token;
  final String refreshToken;
  final String role;
  final Map<String, dynamic> admin;
  final int? ownerProjectId;

  const AdminLoginResponse({
    required this.token,
    required this.refreshToken,
    required this.role,
    required this.admin,
    this.ownerProjectId,
  });

  factory AdminLoginResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;

    final wrappedData = json['data'];
    if (wrappedData is Map) {
      data = Map<String, dynamic>.from(wrappedData);

      final nestedData = data['data'];
      if (nestedData is Map) {
        data = Map<String, dynamic>.from(nestedData);
      }
    }

    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return AdminLoginResponse(
      token: (data['token'] ??
              data['accessToken'] ??
              data['jwt'] ??
              data['access_token'] ??
              '')
          .toString(),
      refreshToken: (data['refreshToken'] ??
              data['refresh_token'] ??
              data['refresh'] ??
              '')
          .toString(),
      role: (data['role'] ?? data['adminRole'] ?? data['type'] ?? '')
          .toString(),
      admin: data['admin'] is Map
          ? Map<String, dynamic>.from(data['admin'])
          : data['user'] is Map
              ? Map<String, dynamic>.from(data['user'])
              : {},
      ownerProjectId: toInt(data['ownerProjectId'] ?? json['ownerProjectId']),
    );
  }
}