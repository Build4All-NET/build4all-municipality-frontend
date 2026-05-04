import 'package:baladiyati/features/admin/manage_service/Domain/Repository/Service_repo.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/entities/service.dart';

class GetServices {
  final ServiceRepository repo;
  GetServices(this.repo);

  Future<List<Service>> call() => repo.getServices();
}