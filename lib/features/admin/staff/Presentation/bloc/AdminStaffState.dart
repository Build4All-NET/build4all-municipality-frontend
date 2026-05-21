import 'package:baladiyati/features/admin/staff/data/Model/AdminUserModel.dart';
import 'package:baladiyati/features/admin/staff/data/Model/UserAssignmentSearchResult.dart';

class AdminStaffState {
  final List<AdminUserModel> allStaffUsers;
  final List<AdminUserModel> visibleStaffUsers;
  final List<String> roles;

  final UserAssignmentSearchResult? assignmentSearchResult;

  final bool loading;
  final bool actionLoading;
  final bool searchLoading;
  final bool rolesLoading;

  final String searchQuery;
  final String selectedRoleName;

  final String? error;
  final String? success;

  const AdminStaffState({
    required this.allStaffUsers,
    required this.visibleStaffUsers,
    required this.roles,
    required this.loading,
    required this.actionLoading,
    required this.searchLoading,
    required this.rolesLoading,
    required this.searchQuery,
    required this.selectedRoleName,
    this.assignmentSearchResult,
    this.error,
    this.success,
  });

  factory AdminStaffState.initial() {
    return const AdminStaffState(
      allStaffUsers: [],
      visibleStaffUsers: [],
      roles: [],
      loading: false,
      actionLoading: false,
      searchLoading: false,
      rolesLoading: false,
      searchQuery: '',
      selectedRoleName: 'STAFF',
    );
  }

  AdminStaffState copyWith({
    List<AdminUserModel>? allStaffUsers,
    List<AdminUserModel>? visibleStaffUsers,
    List<String>? roles,
    UserAssignmentSearchResult? assignmentSearchResult,
    bool clearAssignmentSearchResult = false,
    bool? loading,
    bool? actionLoading,
    bool? searchLoading,
    bool? rolesLoading,
    String? searchQuery,
    String? selectedRoleName,
    String? error,
    String? success,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminStaffState(
      allStaffUsers: allStaffUsers ?? this.allStaffUsers,
      visibleStaffUsers: visibleStaffUsers ?? this.visibleStaffUsers,
      roles: roles ?? this.roles,
      assignmentSearchResult: clearAssignmentSearchResult
          ? null
          : assignmentSearchResult ?? this.assignmentSearchResult,
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      searchLoading: searchLoading ?? this.searchLoading,
      rolesLoading: rolesLoading ?? this.rolesLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRoleName: selectedRoleName ?? this.selectedRoleName,
      error: clearError ? null : error ?? this.error,
      success: clearSuccess ? null : success ?? this.success,
    );
  }
}