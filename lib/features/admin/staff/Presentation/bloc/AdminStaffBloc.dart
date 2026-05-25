import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/staff/data/Model/AdminUserModel.dart';
import 'package:baladiyati/features/admin/staff/data/Service/AdminUserApiService.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/AdminStaffEvent.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/AdminStaffState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminStaffBloc extends Bloc<AdminStaffEvent, AdminStaffState> {
  final AdminUserApiService apiService;

  AdminStaffBloc({required this.apiService}) : super(AdminStaffState.initial()) {
    on<LoadStaffUsers>(_onLoadStaffUsers);
    on<SearchStaffUsersLocally>(_onSearchStaffUsersLocally);
    on<SearchUserForStaffAssignment>(_onSearchUserForStaffAssignment);
    on<AssignUserAsStaff>(_onAssignUserAsStaff);
    on<RemoveStaffRole>(_onRemoveStaffRole);
    on<LoadStaffRoles>(_onLoadStaffRoles);
    on<ClearStaffSearchResult>(_onClearStaffSearchResult);
    on<ClearStaffMessages>(_onClearStaffMessages);
    on<SendStaffRegistrationInvite>(_onSendStaffRegistrationInvite);
  }

  Future<void> _onSendStaffRegistrationInvite(
    SendStaffRegistrationInvite event,
    Emitter<AdminStaffState> emit,
  ) async {
    final email = event.email.trim();
    final fullName = event.fullName.trim();

    if (email.isEmpty) {
      emit(state.copyWith(error: 'EMAIL_REQUIRED', clearSuccess: true));
      return;
    }
    if (fullName.isEmpty) {
      emit(state.copyWith(error: 'FULL_NAME_REQUIRED', clearSuccess: true));
      return;
    }

    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));

    try {
      await apiService.sendStaffRegistrationInvite(email: email, fullName: fullName);
      emit(state.copyWith(actionLoading: false, success: 'STAFF_INVITE_SENT', clearError: true));
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: errorMessage(e), clearSuccess: true));
    }
  }

  Future<void> _onLoadStaffUsers(LoadStaffUsers event, Emitter<AdminStaffState> emit) async {
    emit(state.copyWith(loading: true, selectedRoleName: event.roleName, clearError: true, clearSuccess: true));

    try {
      final users = await apiService.getUsersByRole(roleName: event.roleName);
      emit(state.copyWith(
        loading: false,
        allStaffUsers: users,
        visibleStaffUsers: _applySearch(users, state.searchQuery),
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: errorMessage(e), clearSuccess: true));
    }
  }

  void _onSearchStaffUsersLocally(SearchStaffUsersLocally event, Emitter<AdminStaffState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      visibleStaffUsers: _applySearch(state.allStaffUsers, event.query),
    ));
  }

  Future<void> _onSearchUserForStaffAssignment(
    SearchUserForStaffAssignment event,
    Emitter<AdminStaffState> emit,
  ) async {
    final email = event.email.trim();
    if (email.isEmpty) {
      emit(state.copyWith(error: 'EMAIL_REQUIRED', clearSuccess: true));
      return;
    }

    emit(state.copyWith(searchLoading: true, clearAssignmentSearchResult: true, clearError: true, clearSuccess: true));

    try {
      final result = await apiService.searchUserForAssignment(email: email, roleName: event.roleName);
      emit(state.copyWith(
        searchLoading: false,
        assignmentSearchResult: result,
        selectedRoleName: event.roleName,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(searchLoading: false, error: errorMessage(e), clearSuccess: true));
    }
  }

  Future<void> _onAssignUserAsStaff(AssignUserAsStaff event, Emitter<AdminStaffState> emit) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));

    try {
      await apiService.assignRole(
        userId: event.userId,
        roleName: event.roleName,
        departmentIds: event.departmentIds,
      );

      final users = await apiService.getUsersByRole(roleName: event.roleName);

      emit(state.copyWith(
        actionLoading: false,
        allStaffUsers: users,
        visibleStaffUsers: _applySearch(users, state.searchQuery),
        selectedRoleName: event.roleName,
        clearAssignmentSearchResult: true,
        success: 'STAFF_ASSIGNED',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: errorMessage(e), clearSuccess: true));
    }
  }

  Future<void> _onRemoveStaffRole(RemoveStaffRole event, Emitter<AdminStaffState> emit) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));

    try {
      await apiService.removeRole(userId: event.userId, roleName: event.roleName);
      final users = await apiService.getUsersByRole(roleName: event.roleName);

      emit(state.copyWith(
        actionLoading: false,
        allStaffUsers: users,
        visibleStaffUsers: _applySearch(users, state.searchQuery),
        selectedRoleName: event.roleName,
        success: 'STAFF_ROLE_REMOVED',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: errorMessage(e), clearSuccess: true));
    }
  }

  Future<void> _onLoadStaffRoles(LoadStaffRoles event, Emitter<AdminStaffState> emit) async {
    emit(state.copyWith(rolesLoading: true, clearError: true));

    try {
      final roles = await apiService.getRoles();
      emit(state.copyWith(rolesLoading: false, roles: roles, clearError: true));
    } catch (e) {
      emit(state.copyWith(rolesLoading: false, error: errorMessage(e)));
    }
  }

  void _onClearStaffSearchResult(ClearStaffSearchResult event, Emitter<AdminStaffState> emit) {
    emit(state.copyWith(clearAssignmentSearchResult: true));
  }

  void _onClearStaffMessages(ClearStaffMessages event, Emitter<AdminStaffState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  List<AdminUserModel> _applySearch(List<AdminUserModel> users, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users.where((user) {
      return user.displayName.toLowerCase().contains(q) ||
          user.email.toLowerCase().contains(q) ||
          user.phone.toLowerCase().contains(q) ||
          user.username.toLowerCase().contains(q) ||
          user.roleName.toLowerCase().contains(q) ||
          user.status.toLowerCase().contains(q) ||
          user.departmentNames.toLowerCase().contains(q);
    }).toList();
  }
}
