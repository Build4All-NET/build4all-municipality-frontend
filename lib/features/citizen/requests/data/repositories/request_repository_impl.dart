import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../services/request_api_service.dart';

class CitizenRequestRepositoryImpl implements CitizenRequestRepository {
  final RequestApiService _api;

  CitizenRequestRepositoryImpl(this._api);

  @override
  Future<List<RequestEntity>> getMyRequests() => _api.getMyRequests();

  @override
  Future<RequestEntity> getRequestById(String id) => _api.getRequestById(id);

  @override
  Future<RequestEntity> createRequest({
    required int serviceId,
    required String title,
    required String description,
    String? addressText,
    double? geoLat,
    double? geoLng,
    List<String>? attachmentUrls,
  }) =>
      _api.createRequest(
        serviceId: serviceId,
        title: title,
        description: description,
        addressText: addressText,
        geoLat: geoLat,
        geoLng: geoLng,
        attachmentUrls: attachmentUrls,
      );
}
