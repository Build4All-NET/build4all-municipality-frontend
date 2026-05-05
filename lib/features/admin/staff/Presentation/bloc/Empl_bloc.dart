import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/staff/Domain/Entities/Employe.dart';
import 'package:baladiyati/features/admin/staff/Domain/Usecase/GetEmploye.dart';
import 'package:baladiyati/features/admin/staff/Domain/Usecase/GreateEmploye.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_State.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployees getEmployees;
  final CreateEmployee createEmployee;

  EmployeeBloc(
    this.getEmployees,
    this.createEmployee,
  ) : super(EmployeeState.initial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<SearchEmployees>(_onSearchEmployees);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );

    try {
      final employees = await getEmployees();

      emit(
        state.copyWith(
          loading: false,
          allEmployees: employees,
          visibleEmployees: _applySearch(
            employees,
            state.searchQuery,
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

  Future<void> _onAddEmployee(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      await createEmployee(event.employee);

      final employees = await getEmployees();

      emit(
        state.copyWith(
          actionLoading: false,
          allEmployees: employees,
          visibleEmployees: _applySearch(
            employees,
            state.searchQuery,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: errorMessage(e),
        ),
      );
    }
  }

  void _onSearchEmployees(
    SearchEmployees event,
    Emitter<EmployeeState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: event.query,
        visibleEmployees: _applySearch(
          state.allEmployees,
          event.query,
        ),
      ),
    );
  }

  List<Employee> _applySearch(
    List<Employee> employees,
    String query,
  ) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) return employees;

    return employees.where((employee) {
      return employee.name.toLowerCase().contains(q) ||
          employee.email.toLowerCase().contains(q) ||
          employee.phone.toLowerCase().contains(q) ||
          employee.roleId.toString().contains(q) ||
          employee.depId.toString().contains(q);
    }).toList();
  }
}