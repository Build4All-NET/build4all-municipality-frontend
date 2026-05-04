class ProfileEntity {
  // Build4All core fields
  final int build4allId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final bool? isPublicProfile;
  final String? coreStatus;

  // Municipality fields
  final int? municipalityProfileId;
  final String phone;
  final String address;
  final String? municipalityStatus;
  final int? municipalityId;
  final String? municipalityName;
  final int? ownerProjectLinkId;

  const ProfileEntity({
    required this.build4allId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.profilePictureUrl,
    required this.isPublicProfile,
    required this.coreStatus,
    required this.municipalityProfileId,
    required this.phone,
    required this.address,
    required this.municipalityStatus,
    required this.municipalityId,
    required this.municipalityName,
    required this.ownerProjectLinkId,
  });

  String get fullName {
    final value = '$firstName $lastName'.trim();

    if (value.isNotEmpty) return value;

    if (username.trim().isNotEmpty) return username.trim();

    return email.split('@').first;
  }

  ProfileEntity copyWith({
    int? build4allId,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? profilePictureUrl,
    bool? isPublicProfile,
    String? coreStatus,
    int? municipalityProfileId,
    String? phone,
    String? address,
    String? municipalityStatus,
    int? municipalityId,
    String? municipalityName,
    int? ownerProjectLinkId,
  }) {
    return ProfileEntity(
      build4allId: build4allId ?? this.build4allId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isPublicProfile: isPublicProfile ?? this.isPublicProfile,
      coreStatus: coreStatus ?? this.coreStatus,
      municipalityProfileId:
          municipalityProfileId ?? this.municipalityProfileId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      municipalityStatus: municipalityStatus ?? this.municipalityStatus,
      municipalityId: municipalityId ?? this.municipalityId,
      municipalityName: municipalityName ?? this.municipalityName,
      ownerProjectLinkId: ownerProjectLinkId ?? this.ownerProjectLinkId,
    );
  }
}