import '../entities/service.dart';

abstract class ServiceRepository {
  Future<List<Service>> getServices();
  Future<void> createService(Service service);
  Future<void> deleteService(int id);
  
  Future<void> updateService(int id, Service service);
}
