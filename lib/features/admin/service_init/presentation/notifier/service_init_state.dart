import 'package:meta/meta.dart';

/// Distinct lifecycle phases for the service initialization flow.
enum ServiceInitStatus { initial, loading, success, error }

/// Private sentinel — distinguishes an explicit [null] from "not provided"
/// inside [ServiceInitState.copyWith].
const Object _absent = Object();

/// Immutable domain model representing the full initialization state contract.
@immutable
class ServiceInitState {
  const ServiceInitState({
    required this.status,
    this.errorMessage,
    this.data,
  });

  final ServiceInitStatus status;

  /// Non-null exclusively when [status] == [ServiceInitStatus.error].
  final String? errorMessage;

  /// Deserialized backend response payload; populated on [ServiceInitStatus.success].
  final Map<String, dynamic>? data;

  /// Returns the canonical blank-slate state before any operation is attempted.
  factory ServiceInitState.initial() => const ServiceInitState(
        status: ServiceInitStatus.initial,
      );

  /// Returns a new instance with selectively overridden fields.
  /// Pass an explicit [null] to clear any nullable field.
  ServiceInitState copyWith({
    ServiceInitStatus? status,
    Object? errorMessage = _absent,
    Object? data = _absent,
  }) {
    return ServiceInitState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _absent)
          ? this.errorMessage
          : errorMessage as String?,
      data: identical(data, _absent)
          ? this.data
          : data as Map<String, dynamic>?,
    );
  }
}
