import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/Repository/Service_repo.dart';

class UpdateService {
  final ServiceRepository repo;

  UpdateService(this.repo);

  Future<void> call(int id, ServiceModel service) {
    return repo.update(id, service);
  }
}