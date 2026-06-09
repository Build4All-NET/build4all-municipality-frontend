import 'package:baladiyati/features/admin/violations/data/model/ViolationModel.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/domain/Repository/ViolationRepository.dart';
import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

class ViolationRepositoryImpl implements ViolationRepository {
  final ViolationApiService api;

  ViolationRepositoryImpl(this.api);

  @override
  Future<void> addViolation(Violation violation) {
    return api.createViolation(ViolationModel.fromEntity(violation));
  }

  @override
  Future<List<Violation>> getViolations() async {
    return api.getAllViolations();
  }

  @override
  Future<void> updateViolation(int id, Violation violation) {
    return api.updateViolation(id, ViolationModel.fromEntity(violation));
  }

  @override
  Future<void> deleteViolation(int id) {
    return api.deleteViolation(id);
  }
}