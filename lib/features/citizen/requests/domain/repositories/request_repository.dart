import '../entities/request_entity.dart';

abstract class CitizenRequestRepository {
  Future<List<RequestEntity>> getMyRequests();
  Future<RequestEntity> getRequestById(String id);
  Future<RequestEntity> createRequest({
    required int serviceId,
    required String title,
    required String description,
    String? addressText,
    double? geoLat,
    double? geoLng,
    List<String>? attachmentUrls,
  });
}
