import 'package:baladiyati/features/admin/Role/data/model/RoleModel.dart';
import 'package:baladiyati/features/admin/Role/data/service/Role_Api_Service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleCubit extends Cubit<List<RoleModel>> {
  final RoleApiService api;

  RoleCubit(this.api) : super([]);

  Future<void> load() async {
    try {
      final data = await api.getAll();

      emit(data.map((e) => RoleModel.fromJson(e)).toList());
    } catch (e) {
      print("❌ RoleCubit error: $e");
      emit([]); // مهم حتى ما يعلق الـ UI
    }
  }
}