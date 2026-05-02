import 'package:baladiyati/features/admin/violations/domain/Repository/ViolationRepository.dart';
import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

class GetViolations {
  final ViolationRepository repo;

  GetViolations(this.repo);

  Future<List<Violation>> call() => repo.getViolations();
}