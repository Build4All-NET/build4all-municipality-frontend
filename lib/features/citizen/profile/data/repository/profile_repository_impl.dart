// lib/features/profile/data/repository/profile_repository_impl.dart

import '../../domain/entities/profile_entity.dart';
import '../../domain/repository/profile_repository.dart';
import '../services/profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiService _api;

  ProfileRepositoryImpl({ProfileApiService? api})
      : _api = api ?? ProfileApiService();

  @override
  Future<ProfileEntity> getProfile() async {
    return await _api.getProfile(ownerProjectLinkId: 12);
  }

  @override
  Future<ProfileEntity> updateProfile({
    required int ownerProjectLinkId,
    String? fullName,
    String? phone,
    String? address,
    String? username,
  }) async {
    return await _api.updateProfile(
      ownerProjectLinkId: ownerProjectLinkId,
      fullName: fullName,
      phone: phone,
      address: address,
      username: username,
    );
  }
}
