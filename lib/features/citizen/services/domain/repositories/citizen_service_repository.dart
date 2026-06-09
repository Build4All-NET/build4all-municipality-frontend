import '../entities/service_entity.dart';

abstract class CitizenServiceRepository {
  Future<List<ServiceEntity>> getServices();
  Future<ServiceEntity> getServiceById(int id);
}
