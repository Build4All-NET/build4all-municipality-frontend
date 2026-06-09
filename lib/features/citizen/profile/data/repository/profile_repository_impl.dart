import 'package:baladiyati/features/citizen/profile/domain/repository/profile_repository.dart';

import '../../domain/entities/profile_entity.dart';

import '../models/build4all_profile_model.dart';
import '../models/municipality_profile_model.dart';
import '../models/profile_model.dart';
import '../services/profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiService api;

  const ProfileRepositoryImpl({
    required this.api,
  });

  @override
  Future<ProfileEntity> getProfile() async {
    Build4AllProfileModel? core;
    try {
      core = await api.getBuild4AllProfile();
    } catch (_) {
      // Build4All may be unreachable; fall back to municipality data
    }

    MunicipalityProfileModel? municipality;
    try {
      municipality = await api.getMunicipalityProfile();
    } catch (_) {
      // municipality profile may not exist yet
    }

    if (core == null && municipality == null) {
      throw Exception('Failed to load profile data');
    }

    // If Build4All is down, synthesise a minimal core from municipality data
    core ??= Build4AllProfileModel(
      id: 0,
      firstName: '',
      lastName: '',
      username: municipality!.email.split('@').first,
      email: municipality.email,
      profilePictureUrl: null,
      isPublicProfile: null,
      status: null,
    );

    return ProfileModel.fromParts(core: core, municipality: municipality);
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? profileImagePath,
    bool imageRemoved = false,
    required String phone,
    required String address,
  }) async {
    final core = await api.updateBuild4AllProfile(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      profileImagePath: profileImagePath,
      imageRemoved: imageRemoved,
    );

    final municipality = await api.updateMunicipalityProfile(
      phone: phone,
      address: address,
    );

    return ProfileModel.fromParts(
      core: core,
      municipality: municipality,
    );
  }
}
