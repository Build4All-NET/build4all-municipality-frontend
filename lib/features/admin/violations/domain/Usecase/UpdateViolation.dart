import 'package:baladiyati/features/admin/violations/domain/Repository/ViolationRepository.dart';
import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

class UpdateViolation {
  final ViolationRepository repository;

  UpdateViolation(this.repository);

  Future<void> call(int id, Violation violation) {
    return repository.updateViolation(id, violation);
  }
}