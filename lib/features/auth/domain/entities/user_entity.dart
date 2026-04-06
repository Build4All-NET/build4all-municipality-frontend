// lib/features/auth/domain/entities/user_entity.dart
class UserEntity {
  final int id;
  final String? username;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final String? role;
  final String? status;
  final bool? isVerified;
  final int? municipalityId;
  final String? createdAt;

  const UserEntity({
    required this.id,
    this.username,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.avatarUrl,
    this.role,
    this.status,
    this.isVerified,
    this.municipalityId,
    this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? 0,
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
      role: json['role'],
      status: json['status'],
      isVerified: json['isVerified'],
      municipalityId: json['municipalityId'],
      createdAt: json['createdAt'],
    );
  }

  UserEntity copyWith({
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    String? role,
    String? status,
    bool? isVerified,
    int? municipalityId,
  }) {
    return UserEntity(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      municipalityId: municipalityId ?? this.municipalityId,
      createdAt: createdAt,
    );
  }

  String get displayName {
    if ((fullName ?? '').trim().isNotEmpty) return fullName!.trim();
    if ((username ?? '').trim().isNotEmpty) return username!.trim();
    if ((email ?? '').trim().isNotEmpty) return email!.trim();
    return 'User #$id';
  }

  bool get isCitizen => role?.toUpperCase() == 'CITIZEN';
  bool get isEmployee => role?.toUpperCase() == 'EMPLOYEE';
}
