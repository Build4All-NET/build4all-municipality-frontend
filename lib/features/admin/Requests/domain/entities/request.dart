class Attachment {
  final String fileName;
  final String fileUrl;

  Attachment({
    required this.fileName,
    required this.fileUrl,
  });
}

class RequestEntity {
  final int? id;
  final int municipalityId;
  final int serviceId;
  final int citizenUserId;
  final String title;
  final String description;
  final String category;
  final double geoLat;
  final double geoLng;
  final String addressText;
  final List<Attachment> attachments;

  RequestEntity({
    this.id,
    required this.municipalityId,
    required this.serviceId,
    required this.citizenUserId,
    required this.title,
    required this.description,
    required this.category,
    required this.geoLat,
    required this.geoLng,
    required this.addressText,
    required this.attachments,
  });
}