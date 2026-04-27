// lib/features/auth/data/services/auth_api_service.dart

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';

import '../models/auth_response_model.dart';
import 'auth_token_store.dart';
import 'session_role_store.dart';

class AuthApiService {
  final AuthTokenStore _tokenStore;
  final SessionRoleStore _roleStore;

  AuthApiService({
    AuthTokenStore? tokenStore,
    SessionRoleStore? roleStore,
  })  : _tokenStore = tokenStore ?? AuthTokenStore(),
        _roleStore = roleStore ?? SessionRoleStore();

  Exception _handleDioError(
    DioException e, {
    String fallback = 'Request failed',
  }) {
    final data = e.response?.data;

    String message = fallback;
    String? code;

    if (data is Map<String, dynamic>) {
      message = (data['error'] ?? data['message'] ?? fallback).toString();
      code = data['code']?.toString();
    } else if (data is Map) {
      message = (data['error'] ?? data['message'] ?? fallback).toString();
      code = data['code']?.toString();
    }

    if (code != null && code.isNotEmpty) {
      return AuthException(message, code: code, original: e);
    }

    return AppException(message, original: e);
  }

  // ============================================================
  // REGISTER — Build4All Core
  // POST /auth/users/register
  // ============================================================
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required int municipalityId,
    int? ownerProjectLinkId,
    int? ownerProjectId,
  }) async {
    try {
      final response = await DioClient.build.post(
        '/auth/users/register',
        data: {
          'email': email.trim(),
          'passwordHash': password,
          'fullName': fullName.trim(),
          'phone': phone.trim(),
          'role': role,
          if (ownerProjectLinkId != null)
            'ownerProjectLinkId': ownerProjectLinkId,
          if (ownerProjectId != null) 'ownerProjectId': ownerProjectId,
          'municipality': {'id': municipalityId},
        },
      );

      final authResponse = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      if (authResponse.token.isNotEmpty) {
        await _tokenStore.saveToken(authResponse.token);
        DioClient.setAuthToken(authResponse.token);
      }

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to register user');
    } on AuthException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to register user', original: e);
    }
  }

  // ============================================================
  // LOGIN — Build4All Core
  // POST /auth/users/login
  // ============================================================
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioClient.build.post(
        '/auth/users/login',
        data: {
          'email': email.trim(),
          'passwordHash': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      if (authResponse.token.isNotEmpty) {
        await _tokenStore.saveToken(authResponse.token);
        DioClient.setAuthToken(authResponse.token);
      }

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to login user');
    } on AuthException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to login user', original: e);
    }
  }

  // ============================================================
  // LOGOUT — Build4All Core
  // POST /auth/logout
  // ============================================================
  Future<void> logout() async {
    try {
      await DioClient.build.post('/auth/logout');
    } catch (_) {
      
    }

    await _tokenStore.clearToken();
    await _roleStore.clearRole();
    DioClient.clearAuthToken();
  }

  // ============================================================
  // RESET PASSWORD — Build4All Core
  // POST /auth/reset-password
  // ============================================================
  Future<String> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await DioClient.build.post(
        '/auth/reset-password',
        data: {
          'email': email.trim(),
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      final data = response.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return 'Password reset successfully';
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to reset password');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to reset password', original: e);
    }
  }

  // ============================================================
  // COMPLETE PROFILE — Build4All Core
  // POST /auth/complete-profile
  // ============================================================
  Future<String> completeProfile({
    required String address,
    required String username,
    required int municipalityId,
  }) async {
    try {
      final token = await _tokenStore.getToken();

      if (token != null && token.isNotEmpty) {
        DioClient.setAuthToken(token);
      }

      final response = await DioClient.build.post(
        '/auth/complete-profile',
        data: {
          'address': address.trim(),
          'username': username.trim(),
          'municipality': {'id': municipalityId},
        },
      );

      final data = response.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return 'Success';
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to complete profile');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to complete profile', original: e);
    }
  }

  // ============================================================
  // TOKEN HELPERS
  // ============================================================
  Future<String?> getSavedToken() => _tokenStore.getToken();

  Future<bool> hasToken() => _tokenStore.hasToken();
}