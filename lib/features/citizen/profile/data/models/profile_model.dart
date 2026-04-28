// lib/features/profile/data/models/profile_model.dart

import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.fullName,
    super.phone,
    super.email,
    super.address,
    super.username,
    super.avatarUrl,
    super.municipalityId,
    super.ownerProjectLinkId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
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
}
