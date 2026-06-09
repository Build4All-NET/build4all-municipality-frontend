import '../entities/service_entity.dart';
import '../repositories/citizen_service_repository.dart';

class GetCitizenServices {
  final CitizenServiceRepository repository;
  const GetCitizenServices(this.repository);

  Future<List<ServiceEntity>> call() => repository.getServices();
}
