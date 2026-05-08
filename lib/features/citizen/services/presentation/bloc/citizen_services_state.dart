import '../../domain/entities/citizen_service_entity.dart';

enum CitizenServicesStatus {
  initial,
  loading,
  success,
  failure,
}

class CitizenServicesState {
  final CitizenServicesStatus status;
  final List<CitizenServiceEntity> services;
  final String? errorMessage;

  const CitizenServicesState({
    required this.status,
    required this.services,
    this.errorMessage,
  });

  factory CitizenServicesState.initial() {
    return const CitizenServicesState(
      status: CitizenServicesStatus.initial,
      services: [],
      errorMessage: null,
    );
  }

  CitizenServicesState copyWith({
    CitizenServicesStatus? status,
    List<CitizenServiceEntity>? services,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CitizenServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}