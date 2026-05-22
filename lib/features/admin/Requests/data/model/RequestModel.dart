import 'package:baladiyati/features/admin/Requests/data/model/attachementModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    super.id,
    required super.municipalityId,
    required super.serviceId,
    required super.citizenUserId,
    super.processInstanceKey,
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
      return text.toLowerCase() == 'null' ? '' : text;
    }

    dynamic readNested(Map<String, dynamic> source, List<String> keys) {
      dynamic current = source;

      for (final key in keys) {
        if (current is Map && current.containsKey(key)) {
          current = current[key];
        } else {
          return null;
        }
      }

      return current;
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
      municipalityId: asInt(json['municipalityId'] ?? json['municipality_id']),
      serviceId: asInt(json['serviceId'] ?? json['service_id']),
      citizenUserId: asInt(
        json['citizenUserId'] ??
            json['citizen_user_id'] ??
            json['userId'] ??
            json['user_id'],
      ),
      processInstanceKey: asNullableInt(
        json['processInstanceKey'] ?? json['process_instance_key'],
      ),
      trackingNumber: asString(
        json['trackingNumber'] ?? json['tracking_number'],
      ),
      title: asString(json['title']),
      description: asString(json['description']),
      category: asString(json['category']),
      status: asString(json['status']),
      geoLat: asDouble(json['geoLat'] ?? json['geo_lat']),
      geoLng: asDouble(json['geoLng'] ?? json['geo_lng']),
      addressText: asString(json['addressText'] ?? json['address_text']),
      createdAt: asString(json['createdAt'] ?? json['created_at']),
      updatedAt: asString(json['updatedAt'] ?? json['updated_at']),
      closedAt: asString(json['closedAt'] ?? json['closed_at']),
      municipalityName: asString(
        json['municipalityName'] ??
            json['municipality_name'] ??
            readNested(json, ['municipality', 'nameEn']) ??
            readNested(json, ['municipality', 'name_en']) ??
            readNested(json, ['municipality', 'name']),
      ),
      serviceName: asString(
        json['serviceName'] ??
            json['service_name'] ??
            readNested(json, ['service', 'nameEn']) ??
            readNested(json, ['service', 'name_en']) ??
            readNested(json, ['service', 'name']) ??
            readNested(json, ['service', 'title']),
      ),
      citizenName: asString(
        json['citizenName'] ??
            json['citizen_name'] ??
            readNested(json, ['citizen', 'fullName']) ??
            readNested(json, ['citizen', 'full_name']) ??
            readNested(json, ['citizen', 'name']) ??
            readNested(json, ['user', 'fullName']) ??
            readNested(json, ['user', 'full_name']) ??
            readNested(json, ['user', 'name']),
      ),
      attachments: parseAttachments(
        json['attachments'] ?? json['attachements'] ?? json['files'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'municipalityId': municipalityId,
      'serviceId': serviceId,
      'citizenUserId': citizenUserId,
      'processInstanceKey': processInstanceKey,
      'title': title,
      'description': description,
      'category': category,
      'geoLat': geoLat,
      'geoLng': geoLng,
      'addressText': addressText,
      'attachments': attachments
          .map(
            (e) => e is AttachmentModel
                ? e.toJson()
                : {
                    'fileName': e.fileName,
                    'fileUrl': e.fileUrl,
                  },
          )
          .toList(),
    };
  }
}