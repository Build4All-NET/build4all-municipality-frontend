import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

abstract class ViolationEvent {}

class CreateViolationEvent extends ViolationEvent {
  final Violation violation;

  CreateViolationEvent(this.violation);
}

class LoadViolationsEvent extends ViolationEvent {}