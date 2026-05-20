import '../entities/request_entity.dart';
import '../repositories/request_repository.dart';

class CreateCitizenRequest {
  final CitizenRequestRepository repository;
  const CreateCitizenRequest(this.repository);

  Future<RequestEntity> call({
    required int serviceId,
    required String title,
    required String description,
    String? addressText,
    double? geoLat,
    double? geoLng,
    List<String>? attachmentUrls,
  }) =>
      repository.createRequest(
        serviceId: serviceId,
        title: title,
        description: description,
        addressText: addressText,
        geoLat: geoLat,
        geoLng: geoLng,
        attachmentUrls: attachmentUrls,
      );
}
