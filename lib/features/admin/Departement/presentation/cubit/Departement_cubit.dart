import 'package:baladiyati/features/admin/Departement/domain/Usecases/Add_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Delete_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Get_Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Update_Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/Entities/Departement.dart';

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
  ) : super(
          DepartmentState(
            departments: [],
            filtered: [],
            loading: false,
          ),
        );

  Future<void> fetchDepartments() async {
    emit(state.copyWith(loading: true));

    final data = await getDepartments();

    emit(state.copyWith(
      loading: false,
      departments: data,
      filtered: data,
    ));
  }

  void filterByDepartment(int? id) {
    if (id == null) {
      emit(state.copyWith(filtered: state.departments, selectedId: null));
      return;
    }

    final filtered = state.departments.where((e) => e.id == id).toList();

    emit(state.copyWith(
      filtered: filtered,
      selectedId: id,
    ));
  }

  Future<void> delete(int id) async {
    await deleteDepartment(id);
    fetchDepartments();
  }

  Future<void> add(Department dep) async {
    await addDepartment(dep);
    fetchDepartments();
  }

  Future<void> update(Department dep) async {
    await updateDepartment(dep);
    fetchDepartments();
  }
}