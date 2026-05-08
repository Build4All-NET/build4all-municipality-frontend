class Attachment {
  final String fileName;
  final String fileUrl;

  const Attachment({
    required this.fileName,
    required this.fileUrl,
  });
}

class RequestEntity {
  final int? id;
  final int municipalityId;
  final int serviceId;
  final int citizenUserId;

  final String trackingNumber;
  final String title;
  final String description;
  final String category;
  final String status;

  final double geoLat;
  final double geoLng;
  final String addressText;

  final String createdAt;
  final String updatedAt;
  final String closedAt;

  final String municipalityName;
  final String serviceName;
  final String citizenName;

  final List<Attachment> attachments;

  const RequestEntity({
    this.id,
    required this.municipalityId,
    required this.serviceId,
    required this.citizenUserId,
    required this.trackingNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.geoLat,
    required this.geoLng,
    required this.addressText,
    required this.createdAt,
    required this.updatedAt,
    required this.closedAt,
    required this.municipalityName,
    required this.serviceName,
    required this.citizenName,
    required this.attachments,
  });
}