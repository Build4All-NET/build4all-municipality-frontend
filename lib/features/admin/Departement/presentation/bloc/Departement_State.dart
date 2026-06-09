import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';

class DepartmentState {
  final List<Department> departments;
  final List<Department> filtered;
  final bool loading;
  final bool actionLoading;
  final String? error;
  final int? selectedId;
  final String searchQuery;

  const DepartmentState({
    required this.departments,
    required this.filtered,
    required this.loading,
    required this.actionLoading,
    required this.searchQuery,
    this.error,
    this.selectedId,
  });

  factory DepartmentState.initial() {
    return const DepartmentState(
      departments: [],
      filtered: [],
      loading: false,
      actionLoading: false,
      searchQuery: '',
    );
  }

  DepartmentState copyWith({
    List<Department>? departments,
    List<Department>? filtered,
    bool? loading,
    bool? actionLoading,
    String? error,
    bool clearError = false,
    int? selectedId,
    bool clearSelectedId = false,
    String? searchQuery,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      filtered: filtered ?? this.filtered,
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      error: clearError ? null : error ?? this.error,
      selectedId: clearSelectedId ? null : selectedId ?? this.selectedId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}