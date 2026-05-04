import 'package:baladiyati/features/admin/staff/Domain/Usecase/GetEmploye.dart';
import 'package:baladiyati/features/admin/staff/Domain/Usecase/GreateEmploye.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_State.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployees getEmployees;
  final CreateEmployee createEmployee;

  EmployeeBloc(this.getEmployees, this.createEmployee)
      : super(EmployeeInitial()) {

    on<LoadEmployees>((event, emit) async {
      emit(EmployeeLoading());
      try {
        final employees = await getEmployees();
        emit(EmployeeLoaded(employees));
      } catch (e) {
        emit(EmployeeError(e.toString()));
      }
    });

    on<AddEmployee>((event, emit) async {
      try {
        await createEmployee(event.employee);
        add(LoadEmployees()); // refresh list
      } catch (e) {
        emit(EmployeeError(e.toString()));
      }
    });
  }
}