import 'package:baladiyati/features/admin/manage_service/Domain/Repository/Service_repo.dart';

class DeleteService {
  final ServiceRepository repo;

  DeleteService(this.repo);

  Future<void> call(int id) {
    return repo.delete(id);
  }
}
