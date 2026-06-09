import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Data/service/Service_Api_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/Repository/Service_repo.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceApiService api;

  ServiceRepositoryImpl(this.api);

  @override
  Future<List<ServiceModel>> getAll() {
    return api.getServices();
  }

  @override
  Future<void> create(ServiceModel service) {
    return api.create(service);
  }

  @override
  Future<void> update(int id, ServiceModel service) {
    return api.update(id, service);
  }

  @override
  Future<void> delete(int id) {
    return api.delete(id);
  }
}