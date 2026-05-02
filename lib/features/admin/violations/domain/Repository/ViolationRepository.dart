import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

abstract class ViolationRepository {
  Future<void> addViolation(Violation violation);
  Future<List<Violation>> getViolations();
}