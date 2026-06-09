import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/citizen_service_repository.dart';
import '../services/citizen_service_api.dart';

class CitizenServiceRepositoryImpl implements CitizenServiceRepository {
  final CitizenServiceApi _api;

  CitizenServiceRepositoryImpl(this._api);

  @override
  Future<List<ServiceEntity>> getServices() => _api.getServices();

  @override
  Future<ServiceEntity> getServiceById(int id) => _api.getServiceById(id);
}
