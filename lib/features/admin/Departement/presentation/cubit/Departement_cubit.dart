import 'package:baladiyati/features/admin/Departement/data/Model/Departement_model.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentCubit extends Cubit<List<DepartmentModel>> {
  final DepartmentApiService api;

  DepartmentCubit(this.api) : super([]);

  Future<void> load() async {
    final data = await api.getAll();
      print("🔥 DEPARTMENTS FROM API: $data");

    emit(data);
  }

  Future<void> delete(int id) async {
    await api.delete(id);
    await load();
  }

  Future<void> add(DepartmentModel model) async {
    await api.add(model);
    await load(); // refresh list
  }

  Future<void> update(DepartmentModel model) async {
    await api.update(model.id, model);
    await load(); // refresh list
  }
}