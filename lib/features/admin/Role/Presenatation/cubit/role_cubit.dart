import 'package:baladiyati/features/admin/Role/Presenatation/cubit/Role_state.dart';
import 'package:baladiyati/features/admin/Role/data/service/Role_Api_Service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleCubit extends Cubit<RoleState> {
  final RoleApiService api;

  RoleCubit(this.api) : super(RoleState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true));

    try {
      final roles = await api.getRoles(); // ✔️ صح
      emit(state.copyWith(roles: roles, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }
}