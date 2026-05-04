import '../../domain/entities/profile_entity.dart';

class Build4AllProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final bool? isPublicProfile;
  final String? status;

  const Build4AllProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.profilePictureUrl,
    required this.isPublicProfile,
    required this.status,
  });

  factory Build4AllProfileModel.fromJson(Map<String, dynamic> json) {
    return Build4AllProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString() ??
          json['profileImageUrl']?.toString() ??
          json['avatarUrl']?.toString(),
      isPublicProfile: _readBool(json['isPublicProfile']),
      status: _readStatus(json['status']),
    );
  }
}

bool? _readBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;

  final text = value.toString().trim().toLowerCase();

  if (text == 'true') return true;
  if (text == 'false') return false;

  return null;
}

String? _readStatus(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;

  if (value is Map) {
    return value['name']?.toString() ?? value['status']?.toString();
  }

  return value.toString();
}