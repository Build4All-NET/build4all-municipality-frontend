import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class GetRequest {
  final RequestRepository repo;

  GetRequest(this.repo);

  Future<RequestEntity> call(int id) {
    return repo.getRequest(id);
  }
}