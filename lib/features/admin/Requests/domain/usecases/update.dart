import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class UpdateRequest {
  final RequestRepository repo;

  UpdateRequest(this.repo);

  Future<void> call(int id, RequestEntity request) {
    return repo.updateRequest(id, request);
  }
}