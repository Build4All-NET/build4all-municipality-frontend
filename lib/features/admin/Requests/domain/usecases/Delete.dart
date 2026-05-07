import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';

class DeleteRequest {
  final RequestRepository repo;

  DeleteRequest(this.repo);

  Future<void> call(int id) {
    return repo.deleteRequest(id);
  }
}