import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

abstract class ViolationState {}

class ViolationInitial extends ViolationState {}

class ViolationLoading extends ViolationState {}

class ViolationLoaded extends ViolationState {
  final List<Violation> violations;

  ViolationLoaded(this.violations);
}

class ViolationError extends ViolationState {
  final String message;

  ViolationError(this.message);
}