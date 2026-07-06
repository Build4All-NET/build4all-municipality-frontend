import 'package:baladiyati/features/admin/Requests/domain/Repository/Request_Repo.dart';

class UpdateRequestStatus {
  final RequestRepository repo;

  UpdateRequestStatus(this.repo);

  Future<void> call({
    required int id,
    required String status,
    String? message,
  }) {
    return repo.updateStatus(id, status, message: message);
  }
}