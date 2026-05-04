import '../repository/service_repo.dart';

class DeleteService {
  final ServiceRepository repo;

  DeleteService(this.repo);

  Future<void> call(int id) async {
    await repo.deleteService(id);
  }
}