import 'package:baladiyati/features/admin/Role/data/model/RoleModel.dart';

class RoleState {
  final List<RoleModel> roles;
  final bool loading;

  RoleState({
    required this.roles,
    required this.loading,
  });

  factory RoleState.initial() {
    return RoleState(
      roles: [],
      loading: false,
    );
  }

  RoleState copyWith({
    List<RoleModel>? roles,
    bool? loading,
  }) {
    return RoleState(
      roles: roles ?? this.roles,
      loading: loading ?? this.loading,
    );
  }
}