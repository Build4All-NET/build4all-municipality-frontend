import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class CreateRequest {
  final RequestRepository repo;

  CreateRequest(this.repo);

  Future<void> call(RequestEntity request) {
    return repo.createRequest(request);
  }
}