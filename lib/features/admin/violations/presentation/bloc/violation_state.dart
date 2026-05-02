import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';

abstract class ViolationState {}

class ViolationInitial extends ViolationState {}

class ViolationLoading extends ViolationState {}

class ViolationSuccess extends ViolationState {}
class ViolationCreated extends ViolationState {}

class ViolationError extends ViolationState {
  final String message;

  ViolationError(this.message);
}

// ✅ أهم كلاس
class ViolationLoaded extends ViolationState {
  final List<Violation> violations;

  ViolationLoaded(this.violations);
}