import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/Repository/Service_repo.dart';

class CreateService {
  final ServiceRepository repo;
  CreateService(this.repo);

  Future<void> call(ServiceModel s) => repo.create(s);
}