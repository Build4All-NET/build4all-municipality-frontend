class RequestEntity {
  final String id;
  final String trackingNumber;
  final String title;
  final String description;
  final String status;
  final String? serviceName;
  final String? municipalityName;
  final String? citizenName;
  final String? addressText;
  final double? geoLat;
  final double? geoLng;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;

  const RequestEntity({
    required this.id,
    required this.trackingNumber,
    required this.title,
    required this.description,
    required this.status,
    this.serviceName,
    this.municipalityName,
    this.citizenName,
    this.addressText,
    this.geoLat,
    this.geoLng,
    this.createdAt,
    this.updatedAt,
    this.closedAt,
  });
}
