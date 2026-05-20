import '../entities/service_entity.dart';
import '../repositories/citizen_service_repository.dart';

class GetCitizenServiceById {
  final CitizenServiceRepository repository;
  const GetCitizenServiceById(this.repository);

  Future<ServiceEntity> call(int id) => repository.getServiceById(id);
}
