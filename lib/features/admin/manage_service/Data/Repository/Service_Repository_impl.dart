import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Data/service/Service_Api_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/Repository/Service_repo.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceApiService api;

  ServiceRepositoryImpl(this.api);

  @override
  Future<List<ServiceModel>> getAll() => api.getDepartments();

  @override
  Future<void> create(ServiceModel s) => api.create(s);

  @override
  Future<void> delete(int id) => api.delete(id);

  @override
  Future<void> update(int id, ServiceModel s) => api.update(id, s);
}