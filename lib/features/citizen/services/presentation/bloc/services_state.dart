import 'package:baladiyati/features/citizen/services/domain/entities/service_entity.dart';

class CitizenServicesState {
  final bool isLoading;
  final List<ServiceEntity> services;
  final String? errorMessage;

  const CitizenServicesState({
    this.isLoading = false,
    this.services = const [],
    this.errorMessage,
  });

  CitizenServicesState copyWith({
    bool? isLoading,
    List<ServiceEntity>? services,
    String? errorMessage,
  }) {
    return CitizenServicesState(
      isLoading: isLoading ?? this.isLoading,
      services: services ?? this.services,
      errorMessage: errorMessage,
    );
  }
}
