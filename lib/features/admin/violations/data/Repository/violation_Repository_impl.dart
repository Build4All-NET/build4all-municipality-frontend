import 'package:baladiyati/features/admin/violations/data/model/ViolationModel.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/domain/Repository/ViolationRepository.dart';

import '../../domain/entities/violation.dart';


class ViolationRepositoryImpl implements ViolationRepository {
  final ViolationApiService api;

  ViolationRepositoryImpl(this.api);

  @override
  Future<void> addViolation(Violation violation) async {
    final model = ViolationModel(
      title: violation.title,
      description: violation.description,
      citizenName: violation.citizenName,
      amount: violation.amount,
      departmentId: violation.departmentId,
      location: violation.location,
      violationDate: violation.violationDate,
    );

    await api.createViolation(model);
  }

  @override
  Future<List<Violation>> getViolations() async {
    final list = await api.getAllViolations();

    return list
        .map((e) => Violation(
              title: e.title,
              description: e.description,
              citizenName: e.citizenName,
              amount: e.amount,
              departmentId: e.departmentId,
              location: e.location,
              violationDate: e.violationDate,
            ))
        .toList();
  }
}