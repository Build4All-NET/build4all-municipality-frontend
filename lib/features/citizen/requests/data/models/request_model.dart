import '../../domain/entities/request_entity.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.trackingNumber,
    required super.title,
    required super.description,
    required super.status,
    super.serviceName,
    super.municipalityName,
    super.citizenName,
    super.addressText,
    super.geoLat,
    super.geoLng,
    super.createdAt,
    super.updatedAt,
    super.closedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      trackingNumber: (json['trackingNumber'] ?? json['tracking_number'] ?? json['number'] ?? json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      serviceName: json['serviceName']?.toString() ?? json['service_name']?.toString(),
      municipalityName: json['municipalityName']?.toString(),
      citizenName: json['citizenName']?.toString() ?? json['citizen_name']?.toString(),
      addressText: json['addressText']?.toString() ?? json['address_text']?.toString(),
      geoLat: _toDouble(json['geoLat'] ?? json['geo_lat']),
      geoLng: _toDouble(json['geoLng'] ?? json['geo_lng']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
      closedAt: _parseDate(json['closedAt'] ?? json['closed_at']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    return double.tryParse(v.toString());
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  Map<String, dynamic> toCreateJson({
    required int serviceId,
    List<String>? attachmentUrls,
  }) {
    List<Map<String, dynamic>>? attachments;
    if (attachmentUrls != null && attachmentUrls.isNotEmpty) {
      attachments = attachmentUrls.map((url) {
        final fileName = url.split('/').last;
        final ext = fileName.split('.').last.toLowerCase();
        final fileType = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)
            ? 'image'
            : ext == 'pdf'
                ? 'pdf'
                : 'document';
        return {'fileName': fileName, 'fileUrl': url, 'fileType': fileType};
      }).toList();
    }

    return {
      'title': title,
      'description': description,
      if (addressText != null && addressText!.isNotEmpty) 'addressText': addressText,
      if (geoLat != null) 'geoLat': geoLat,
      if (geoLng != null) 'geoLng': geoLng,
      if (attachments != null) 'attachments': attachments,
    };
  }
}
