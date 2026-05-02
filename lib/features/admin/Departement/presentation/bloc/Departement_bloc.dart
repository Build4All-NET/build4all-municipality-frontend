import 'package:baladiyati/features/admin/Departement/domain/Usecases/Get_Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_Event.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  final GetDepartments getDepartments;

  DepartmentBloc(this.getDepartments) : super(DepartmentInitial()) {
    on<LoadDepartments>((event, emit) async {
      emit(DepartmentLoading());
      try {
        final data = await getDepartments();
        emit(DepartmentLoaded(data));
      } catch (e) {
        emit(DepartmentError(e.toString()));
      }
    });
  }
}