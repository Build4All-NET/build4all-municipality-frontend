import '../entities/profile_entity.dart';
import 'package:baladiyati/core/utils/picked_file.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    PickedFileData? profileImage,
    bool imageRemoved = false,
    required String phone,
    required String address,
  });
}