class MunicipalityProfileModel {
  final int id;
  final int? build4allId;
  final String email;
  final String phone;
  final String address;
  final String? status;
  final int? municipalityId;
  final String? municipalityName;
  final int? ownerProjectLinkId;

  const MunicipalityProfileModel({
    required this.id,
    required this.build4allId,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.municipalityId,
    required this.municipalityName,
    required this.ownerProjectLinkId,
  });

  factory MunicipalityProfileModel.fromJson(Map<String, dynamic> json) {
    return MunicipalityProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      build4allId: int.tryParse(json['build4allId']?.toString() ?? ''),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      status: json['status']?.toString(),
      municipalityId: int.tryParse(json['municipalityId']?.toString() ?? ''),
      municipalityName: json['municipalityName']?.toString(),
      ownerProjectLinkId:
          int.tryParse(json['ownerProjectLinkId']?.toString() ?? ''),
    );
  }
}