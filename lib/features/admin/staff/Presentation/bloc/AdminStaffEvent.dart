import 'package:baladiyati/features/admin/staff/data/Model/UserAssignmentSearchResult.dart';

abstract class AdminStaffEvent {}

class LoadStaffUsers extends AdminStaffEvent {
  final String roleName;
  LoadStaffUsers({this.roleName = 'STAFF'});
}

class SearchStaffUsersLocally extends AdminStaffEvent {
  final String query;
  SearchStaffUsersLocally(this.query);
}

class SearchUserForStaffAssignment extends AdminStaffEvent {
  final String email;
  final String roleName;
  SearchUserForStaffAssignment({required this.email, this.roleName = 'STAFF'});
}

class AssignUserAsStaff extends AdminStaffEvent {
  final int userId;
  final String roleName;
  final List<int> departmentIds;

  AssignUserAsStaff({
    required this.userId,
    this.roleName = 'STAFF',
    required this.departmentIds,
  });
}

class RemoveStaffRole extends AdminStaffEvent {
  final int userId;
  final String roleName;
  RemoveStaffRole({required this.userId, this.roleName = 'STAFF'});
}

class SendStaffRegistrationInvite extends AdminStaffEvent {
  final String email;
  final String fullName;
  SendStaffRegistrationInvite({required this.email, required this.fullName});
}

class LoadStaffRoles extends AdminStaffEvent {}

class ClearStaffSearchResult extends AdminStaffEvent {}

class ClearStaffMessages extends AdminStaffEvent {}
