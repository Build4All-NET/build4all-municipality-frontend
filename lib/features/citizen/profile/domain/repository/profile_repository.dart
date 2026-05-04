import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? profileImagePath,
    bool imageRemoved = false,
    required String phone,
    required String address,
  });
}