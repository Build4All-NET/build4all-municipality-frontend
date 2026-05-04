import '../entities/service.dart';
import '../repository/service_repo.dart';

class AddService {
  final ServiceRepository repo;

  AddService(this.repo);

  Future<void> call(Service service) async {
    await repo.createService(service);
  }
}