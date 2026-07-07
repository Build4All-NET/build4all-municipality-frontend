import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo.dart';

class MarkRequestPaid {
  final RequestRepository repo;

  MarkRequestPaid(this.repo);

  Future<void> call(int id) {
    return repo.markPaid(id);
  }
}
