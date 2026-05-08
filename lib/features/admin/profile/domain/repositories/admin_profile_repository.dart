import '../entities/admin_profile_entity.dart';

abstract class AdminProfileRepository {
  Future<AdminProfileEntity> getProfile();
}