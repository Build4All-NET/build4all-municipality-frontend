import 'package:baladiyati/features/admin/Requests/data/model/attachementModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    super.id,
    required super.municipalityId,
    required super.serviceId,
    required super.citizenUserId,
    required super.trackingNumber,
    required super.title,
    required super.description,
    required super.category,
    required super.status,
    required super.geoLat,
    required super.geoLng,
    required super.addressText,
    required super.createdAt,
    required super.updatedAt,
    required super.closedAt,
    required super.municipalityName,
    required super.serviceName,
    required super.citizenName,
    required super.attachments,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? asNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double asDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    String asString(dynamic value) {
      final text = value?.toString().trim() ?? '';
      return text == 'null' ? '' : text;
    }

    List<AttachmentModel> parseAttachments(dynamic value) {
      if (value is! List) return [];

      return value
          .whereType<Map>()
          .map((e) => AttachmentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return RequestModel(
      id: asNullableInt(json['id']),
      municipalityId: asInt(json['municipalityId']),
      serviceId: asInt(json['serviceId']),
      citizenUserId: asInt(json['citizenUserId']),
      trackingNumber: asString(json['trackingNumber']),
      title: asString(json['title']),
      description: asString(json['description']),
      category: asString(json['category']),
      status: asString(json['status']),
      geoLat: asDouble(json['geoLat']),
      geoLng: asDouble(json['geoLng']),
      addressText: asString(json['addressText']),
      createdAt: asString(json['createdAt']),
      updatedAt: asString(json['updatedAt']),
      closedAt: asString(json['closedAt']),
      municipalityName: asString(json['municipalityName']),
      serviceName: asString(json['serviceName']),
      citizenName: asString(json['citizenName']),
      attachments: parseAttachments(json['attachments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'municipalityId': municipalityId,
      'serviceId': serviceId,
      'citizenUserId': citizenUserId,
      'title': title,
      'description': description,
      'category': category,
      'geoLat': geoLat,
      'geoLng': geoLng,
      'addressText': addressText,
      'attachments': attachments
          .map((e) => e is AttachmentModel
              ? e.toJson()
              : {
                  'fileName': e.fileName,
                  'fileUrl': e.fileUrl,
                })
          .toList(),
    };
  }
}