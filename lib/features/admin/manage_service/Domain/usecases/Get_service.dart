import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/Repository/Service_repo.dart';

class GetServices {
  final ServiceRepository repo;
  GetServices(this.repo);

  Future<List<ServiceModel>> call() => repo.getAll();
}