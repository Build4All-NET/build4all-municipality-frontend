import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class GetAllRequestsAdmin {
  final RequestRepository repo;

  GetAllRequestsAdmin(this.repo);

  Future<List<RequestEntity>> call() {
    return repo.getAllRequestsAdmin();
  }
}