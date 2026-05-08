import '../entities/citizen_service_entity.dart';
import '../repositories/citizen_service_repository.dart';

class GetCitizenServicesUseCase {
  final CitizenServiceRepository _repository;

  const GetCitizenServicesUseCase(this._repository);

  Future<List<CitizenServiceEntity>> call() {
    return _repository.getCitizenServices();
  }
}