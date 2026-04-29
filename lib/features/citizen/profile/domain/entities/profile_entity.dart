// lib/features/profile/domain/entities/profile_entity.dart

class ProfileEntity {
  final int id;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? address;
  final String? username;
  final String? avatarUrl;
  final int? municipalityId;
  final int? ownerProjectLinkId;

  const ProfileEntity({
    required this.id,
    this.fullName,
    this.phone,
    this.email,
    this.address,
    this.username,
    this.avatarUrl,
    this.municipalityId,
    this.ownerProjectLinkId,
  });

  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      id: json['id'] ?? 0,
      fullName: json['fullName'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      municipalityId: json['municipalityId'],
      ownerProjectLinkId: json['ownerProjectLinkId'],
    );
  }

  ProfileEntity copyWith({
    String? fullName,
    String? phone,
    String? address,
    String? username,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email,
      address: address ?? this.address,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      municipalityId: municipalityId,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}
