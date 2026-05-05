import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getAll();
  Future<void> create(ServiceModel s);
  Future<void> delete(int id);
  Future<void> update(int id, ServiceModel s);
}