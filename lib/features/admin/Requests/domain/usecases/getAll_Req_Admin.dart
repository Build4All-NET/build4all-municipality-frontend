import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class GetAllRequestsAdmin {
  final RequestRepository repo;

  GetAllRequestsAdmin(this.repo);

  Future<List<RequestEntity>> call({
    int? departmentId,
    String? status,
  }) {
    return repo.getAllRequestsAdmin(
      departmentId: departmentId,
      status: status,
    );
  }
}