import 'package:baladiyati/features/admin/Requests/data/model/attachementModel.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';



class RequestModel extends RequestEntity {
  RequestModel({
    int? id,
    required int municipalityId,
    required int serviceId,
    required int citizenUserId,
    required String title,
    required String description,
    required String category,
    required double geoLat,
    required double geoLng,
    required String addressText,
    required List<AttachmentModel> attachments,
  }) : super(
          id: id,
          municipalityId: municipalityId,
          serviceId: serviceId,
          citizenUserId: citizenUserId,
          title: title,
          description: description,
          category: category,
          geoLat: geoLat,
          geoLng: geoLng,
          addressText: addressText,
          attachments: attachments,
        );

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      municipalityId: json['municipalityId'],
      serviceId: json['serviceId'],
      citizenUserId: json['citizenUserId'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      geoLat: (json['geoLat'] as num).toDouble(),
      geoLng: (json['geoLng'] as num).toDouble(),
      addressText: json['addressText'],
      attachments: (json['attachments'] as List)
          .map((e) => AttachmentModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "municipalityId": municipalityId,
      "serviceId": serviceId,
      "citizenUserId": citizenUserId,
      "title": title,
      "description": description,
      "category": category,
      "geoLat": geoLat,
      "geoLng": geoLng,
      "addressText": addressText,
      "attachments":
          attachments.map((e) => (e as AttachmentModel).toJson()).toList(),
    };
  }
}