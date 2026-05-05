import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Add_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Delete_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Get_Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Update_Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  final GetDepartments getDepartments;
  final AddDepartment addDepartment;
  final DeleteDepartment deleteDepartment;
  final UpdateDepartment updateDepartment;

  DepartmentCubit(
    this.getDepartments,
    this.addDepartment,
    this.deleteDepartment,
    this.updateDepartment,
  ) : super(DepartmentState.initial());

  Future<void> fetchDepartments() async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );

    try {
      final data = await getDepartments();

      emit(
        state.copyWith(
          loading: false,
          departments: data,
          filtered: _applyFilters(
            departments: data,
            selectedId: state.selectedId,
            query: state.searchQuery,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: errorMessage(e),
        ),
      );
    }
  }

  void filterByDepartment(int? id) {
    emit(
      state.copyWith(
        selectedId: id,
        clearSelectedId: id == null,
        filtered: _applyFilters(
          departments: state.departments,
          selectedId: id,
          query: state.searchQuery,
        ),
      ),
    );
  }

  void searchDepartments(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filtered: _applyFilters(
          departments: state.departments,
          selectedId: state.selectedId,
          query: query,
        ),
      ),
    );
  }

  void clearSearch() {
    emit(
      state.copyWith(
        searchQuery: '',
        filtered: _applyFilters(
          departments: state.departments,
          selectedId: state.selectedId,
          query: '',
        ),
      ),
    );
  }

  Future<bool> delete(int id) async {
    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      await deleteDepartment(id);
      final data = await getDepartments();

      emit(
        state.copyWith(
          actionLoading: false,
          departments: data,
          filtered: _applyFilters(
            departments: data,
            selectedId: state.selectedId,
            query: state.searchQuery,
          ),
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: errorMessage(e),
        ),
      );

      return false;
    }
  }

  Future<bool> add(Department dep) async {
    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      await addDepartment(dep);
      final data = await getDepartments();

      emit(
        state.copyWith(
          actionLoading: false,
          departments: data,
          filtered: _applyFilters(
            departments: data,
            selectedId: state.selectedId,
            query: state.searchQuery,
          ),
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: errorMessage(e),
        ),
      );

      return false;
    }
  }

  Future<bool> update(Department dep) async {
    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      await updateDepartment(dep);
      final data = await getDepartments();

      emit(
        state.copyWith(
          actionLoading: false,
          departments: data,
          filtered: _applyFilters(
            departments: data,
            selectedId: state.selectedId,
            query: state.searchQuery,
          ),
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: errorMessage(e),
        ),
      );

      return false;
    }
  }

  List<Department> _applyFilters({
    required List<Department> departments,
    required int? selectedId,
    required String query,
  }) {
    var result = departments;

    if (selectedId != null) {
      result = result.where((e) => e.id == selectedId).toList();
    }

    final q = query.trim().toLowerCase();

    if (q.isNotEmpty) {
      result = result.where((department) {
        final name = department.name.toLowerCase();
        final description = department.description.toLowerCase();

        return name.contains(q) || description.contains(q);
      }).toList();
    }

    return result;
  }
}