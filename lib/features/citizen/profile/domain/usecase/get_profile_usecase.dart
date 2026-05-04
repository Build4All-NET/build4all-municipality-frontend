import 'package:baladiyati/features/citizen/profile/domain/repository/profile_repository.dart';

import '../entities/profile_entity.dart';


class GetProfileUseCase {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  Future<ProfileEntity> call() {
    return repository.getProfile();
  }
}