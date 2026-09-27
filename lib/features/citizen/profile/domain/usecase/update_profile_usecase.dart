import 'package:baladiyati/features/citizen/profile/domain/repository/profile_repository.dart';

import '../entities/profile_entity.dart';
import 'package:baladiyati/core/utils/picked_file.dart';


class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<ProfileEntity> call({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    PickedFileData? profileImage,
    bool imageRemoved = false,
    required String phone,
    required String address,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      profileImage: profileImage,
      imageRemoved: imageRemoved,
      phone: phone,
      address: address,
    );
  }
}