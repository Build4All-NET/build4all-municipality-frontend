import 'package:baladiyati/features/admin/violations/domain/Repository/ViolationRepository.dart';
import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

class AddViolation {
  final ViolationRepository repository;

  AddViolation(this.repository);

  Future<void> call(Violation violation) {
    return repository.addViolation(violation);
  }
}