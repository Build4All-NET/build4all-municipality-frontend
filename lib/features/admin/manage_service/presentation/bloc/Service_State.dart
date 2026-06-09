import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';

class ServiceState {
  final List<ServiceModel> allServices;
  final List<ServiceModel> visibleServices;
  final bool loading;
  final bool actionLoading;
  final String? error;
  final String query;
  final int? selectedDepartmentId;

  const ServiceState({
    required this.allServices,
    required this.visibleServices,
    required this.loading,
    required this.actionLoading,
    this.error,
    required this.query,
    this.selectedDepartmentId,
  });

  factory ServiceState.initial() {
    return const ServiceState(
      allServices: [],
      visibleServices: [],
      loading: false,
      actionLoading: false,
      query: '',
    );
  }

  ServiceState copyWith({
    List<ServiceModel>? allServices,
    List<ServiceModel>? visibleServices,
    bool? loading,
    bool? actionLoading,
    String? error,
    bool clearError = false,
    String? query,
    int? selectedDepartmentId,
    bool clearSelectedDepartmentId = false,
  }) {
    return ServiceState(
      allServices: allServices ?? this.allServices,
      visibleServices: visibleServices ?? this.visibleServices,
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      error: clearError ? null : error ?? this.error,
      query: query ?? this.query,
      selectedDepartmentId: clearSelectedDepartmentId
          ? null
          : selectedDepartmentId ?? this.selectedDepartmentId,
    );
  }
}