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
    final municipality = json['municipality'];

    int? resolvedMunicipalityId;
    String? resolvedMunicipalityName;

    if (municipality is Map) {
      resolvedMunicipalityId = int.tryParse(
        municipality['id']?.toString() ?? '',
      );
      resolvedMunicipalityName =
          municipality['nameAR']?.toString() ??
          municipality['name']?.toString() ??
          municipality['municipalityName']?.toString() ??
          municipality['title']?.toString();
    }

    resolvedMunicipalityId ??= int.tryParse(
      json['municipalityId']?.toString() ?? '',
    );

    resolvedMunicipalityName ??=
        json['municipalityNameAR']?.toString() ??
        json['municipalityNameEN']?.toString() ??
        json['municipalityName']?.toString() ??
        json['municipality_name']?.toString();

    return MunicipalityProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      build4allId: int.tryParse(json['build4allId']?.toString() ?? ''),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      status: json['status']?.toString(),
      municipalityId: resolvedMunicipalityId,
      municipalityName: resolvedMunicipalityName,
      ownerProjectLinkId: int.tryParse(
        json['ownerProjectLinkId']?.toString() ?? '',
      ),
    );
  }
}