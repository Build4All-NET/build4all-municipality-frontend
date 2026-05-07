import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo.dart';
import 'package:baladiyati/features/admin/Requests/domain/entities/request.dart';

class GetOneRequestAdmin {
  final RequestRepository repo;

  GetOneRequestAdmin(this.repo);

  Future<RequestEntity> call(int id) {
    return repo.getRequestAdmin(id);
  }
}