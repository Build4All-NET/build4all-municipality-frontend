import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';

class EmployeeState {
  final List<Employee> allEmployees;
  final List<Employee> visibleEmployees;
  final bool loading;
  final bool actionLoading;
  final String? error;
  final String searchQuery;

  const EmployeeState({
    required this.allEmployees,
    required this.visibleEmployees,
    required this.loading,
    required this.actionLoading,
    required this.searchQuery,
    this.error,
  });

  factory EmployeeState.initial() {
    return const EmployeeState(
      allEmployees: [],
      visibleEmployees: [],
      loading: false,
      actionLoading: false,
      searchQuery: '',
    );
  }

  EmployeeState copyWith({
    List<Employee>? allEmployees,
    List<Employee>? visibleEmployees,
    bool? loading,
    bool? actionLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return EmployeeState(
      allEmployees: allEmployees ?? this.allEmployees,
      visibleEmployees: visibleEmployees ?? this.visibleEmployees,
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}