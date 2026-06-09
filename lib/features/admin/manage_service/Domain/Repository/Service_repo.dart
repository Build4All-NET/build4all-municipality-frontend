import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getAll();

  Future<void> create(ServiceModel service);

  Future<void> update(int id, ServiceModel service);

  Future<void> delete(int id);
}