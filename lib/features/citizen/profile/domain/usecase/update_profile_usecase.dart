import 'package:baladiyati/features/citizen/profile/domain/repository/profile_repository.dart';

import '../entities/profile_entity.dart';


class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<ProfileEntity> call({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? profileImagePath,
    bool imageRemoved = false,
    required String phone,
    required String address,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      profileImagePath: profileImagePath,
      imageRemoved: imageRemoved,
      phone: phone,
      address: address,
    );
  }
}