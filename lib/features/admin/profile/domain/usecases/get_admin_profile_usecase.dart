import '../entities/admin_profile_entity.dart';
import '../repositories/admin_profile_repository.dart';

class GetAdminProfileUseCase {
  final AdminProfileRepository repository;

  GetAdminProfileUseCase(this.repository);

  Future<AdminProfileEntity> call() {
    return repository.getProfile();
  }
}