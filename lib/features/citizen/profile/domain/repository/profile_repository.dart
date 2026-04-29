// lib/features/profile/domain/repository/profile_repository.dart

import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  // Get current user profile
  Future<ProfileEntity> getProfile();

  // Update current user profile
  Future<ProfileEntity> updateProfile({
    required int ownerProjectLinkId,
    String? fullName,
    String? phone,
    String? address,
    String? username,
  });
}
