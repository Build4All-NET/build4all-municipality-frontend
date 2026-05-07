import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';

class UpdateRequestStatus {
  final RequestRepository repo;

  UpdateRequestStatus(this.repo);

  Future<void> call(int id, String status) {
    return repo.updateStatus(id, status);
  }
}