import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/staff/data/Model/AdminUserModel.dart';
import 'package:baladiyati/features/admin/staff/data/Model/UserAssignmentSearchResult.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

class AdminUserApiService {
  final Dio dio;

  AdminUserApiService({Dio? dio}) : dio = dio ?? DioClient.muni;

  Future<List<AdminUserModel>> getUsersByRole({
    String roleName = 'STAFF',
  }) async {
    final response = await dio.get(
      '/api/admin/users/by-role',
      queryParameters: {
        'roleName': roleName,
      },
    );

    final data = response.data;

    if (data is! List) {
      throw Exception(AppStrings.current.errInvalidResponse);
    }

    return data
        .whereType<Map>()
        .map((item) => AdminUserModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<UserAssignmentSearchResult> searchUserForAssignment({
    required String email,
    String roleName = 'STAFF',
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw Exception(AppStrings.current.errEmailRequired);
    }

    final response = await dio.get(
      '/api/admin/users/search-for-assignment',
      queryParameters: {
        'email': cleanEmail,
        'roleName': roleName,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception(AppStrings.current.errInvalidResponse);
    }

    return UserAssignmentSearchResult.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<List<String>> getRoles() async {
    final response = await dio.get('/api/admin/roles');

    final data = response.data;

    if (data is! List) {
      throw Exception(AppStrings.current.errInvalidResponse);
    }

    return data
        .map((item) => item.toString().trim())
        .where((role) => role.isNotEmpty)
        .toList();
  }

  Future<AdminUserModel> assignRole({
    required int userId,
    required String roleName,
    List<int> departmentIds = const [],
  }) async {
    if (userId <= 0) {
      throw Exception(AppStrings.current.errInvalidUserId);
    }

    final cleanRole = roleName.trim();

    if (cleanRole.isEmpty) {
      throw Exception(AppStrings.current.errRoleRequired);
    }

    final Map<String, dynamic> body = {
      'userId': userId,
      'roleName': cleanRole,
    };

    if (departmentIds.isNotEmpty) {
      body['departmentAccessIds'] = departmentIds;
    }

    final response = await dio.post(
      '/api/admin/roles/assign',
      data: body,
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception(AppStrings.current.errInvalidResponse);
    }

    return AdminUserModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<void> sendStaffRegistrationInvite({
    required String email,
    required String fullName,
  }) async {
    final cleanEmail = email.trim();
    final cleanName = fullName.trim();

    if (cleanEmail.isEmpty) {
      throw Exception(AppStrings.current.errEmailRequired);
    }

    if (cleanName.isEmpty) {
      throw Exception(AppStrings.current.errFullNameRequired);
    }

    await dio.post(
      '/api/admin/staff/invite-registration',
      data: {
        'email': cleanEmail,
        'fullName': cleanName,
      },
    );
  }

  Future<AdminUserModel> removeRole({
    required int userId,
    required String roleName,
  }) async {
    if (userId <= 0) {
      throw Exception(AppStrings.current.errInvalidUserId);
    }

    final cleanRole = roleName.trim();

    if (cleanRole.isEmpty) {
      throw Exception(AppStrings.current.errRoleRequired);
    }

    final response = await dio.delete(
      '/api/admin/users/$userId/roles/$cleanRole',
    );

    final data = response.data;

    if (data is! Map) {
      throw Exception(AppStrings.current.errInvalidResponse);
    }

    return AdminUserModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}
