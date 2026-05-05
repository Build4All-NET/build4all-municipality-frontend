import '../../domain/Entities/Departement.dart';

class DepartmentState {
  final List<Department> departments;
  final List<Department> filtered;
  final bool loading;
  final int? selectedId;

  DepartmentState({
    required this.departments,
    required this.filtered,
    required this.loading,
    this.selectedId,
  });

  DepartmentState copyWith({
    List<Department>? departments,
    List<Department>? filtered,
    bool? loading,
    int? selectedId,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      filtered: filtered ?? this.filtered,
      loading: loading ?? this.loading,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}