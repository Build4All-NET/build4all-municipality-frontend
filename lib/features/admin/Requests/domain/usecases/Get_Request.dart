import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class GetAllRequests {
  final RequestRepository repository;

  GetAllRequests(this.repository);

  Future<List<RequestEntity>> call({
    int? departmentId,
    String? status,
  }) {
    return repository.getRequests(
      departmentId: departmentId,
      status: status,
    );
  }
}