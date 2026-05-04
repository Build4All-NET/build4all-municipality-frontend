import 'package:baladiyati/features/admin/violations/domain/Repository/ViolationRepository.dart';

class DeleteViolation {
  final ViolationRepository repository;

  DeleteViolation(this.repository);

  Future<void> call(int id) {
    return repository.deleteViolation(id);
  }
}