import '../../domain/entities/profile_entity.dart';
import 'build4all_profile_model.dart';
import 'municipality_profile_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.build4allId,
    required super.firstName,
    required super.lastName,
    required super.username,
    required super.email,
    required super.profilePictureUrl,
    required super.isPublicProfile,
    required super.coreStatus,
    required super.municipalityProfileId,
    required super.phone,
    required super.address,
    required super.municipalityStatus,
    required super.municipalityId,
    required super.municipalityName,
    required super.ownerProjectLinkId,
  });

  factory ProfileModel.fromParts({
    required Build4AllProfileModel core,
    MunicipalityProfileModel? municipality,
  }) {
    return ProfileModel(
      build4allId: core.id,
      firstName: core.firstName,
      lastName: core.lastName,
      username: core.username,
      email: core.email,
      profilePictureUrl: core.profilePictureUrl,
      isPublicProfile: core.isPublicProfile,
      coreStatus: core.status,
      municipalityProfileId: municipality?.id,
      phone: municipality?.phone ?? '',
      address: municipality?.address ?? '',
      municipalityStatus: municipality?.status,
      municipalityId: municipality?.municipalityId,
      municipalityName: municipality?.municipalityName,
      ownerProjectLinkId: municipality?.ownerProjectLinkId,
    );
  }
}