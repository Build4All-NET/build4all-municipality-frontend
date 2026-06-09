import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

abstract class ViolationEvent {}

class LoadViolationsEvent extends ViolationEvent {}

class CreateViolationEvent extends ViolationEvent {
  final Violation violation;

  CreateViolationEvent(this.violation);
}

class UpdateViolationEvent extends ViolationEvent {
  final int id;
  final Violation violation;

  UpdateViolationEvent({
    required this.id,
    required this.violation,
  });
}

class DeleteViolationEvent extends ViolationEvent {
  final int id;

  DeleteViolationEvent(this.id);
}