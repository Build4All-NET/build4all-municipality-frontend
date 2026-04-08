// lib/features/auth/domain/entities/municipality_entity.dart
class MunicipalityEntity {
  final int id;
  final String? nameAr;
  final String? nameEn;
  final String? nameFr;
  final String? logoUrl;
 // final String? phone;
  final String? email;
  final String? addressText;
  final double? geoLat;
  final double? geoLng;
  final bool? isActive;
  final String? createdAt;

  const MunicipalityEntity({
    required this.id,
    this.nameAr,
    this.nameEn,
    this.nameFr,
    this.logoUrl,
   // this.phone,
    this.email,
    this.addressText,
    this.geoLat,
    this.geoLng,
    this.isActive,
    this.createdAt,
  });

  factory MunicipalityEntity.fromJson(Map<String, dynamic> json) {
    return MunicipalityEntity(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      nameFr: json['nameFr'],
      logoUrl: json['logoUrl'],
      //phone: json['phone'],
      email: json['email'],
      addressText: json['addressText'],
      geoLat: json['geoLat']?.toDouble(),
      geoLng: json['geoLng']?.toDouble(),
      isActive: json['isActive'],
      createdAt: json['createdAt'],
    );
  }

  // Returns name based on language code
  String getName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return nameAr ?? nameEn ?? 'بلدية';
      case 'fr':
        return nameFr ?? nameEn ?? 'Municipalité';
      default:
        return nameEn ?? nameAr ?? 'Municipality';
    }
  }
}
