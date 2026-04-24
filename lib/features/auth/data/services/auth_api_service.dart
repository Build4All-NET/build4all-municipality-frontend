// lib/features/auth/data/services/auth_api_service.dart

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:baladiyati/core/exceptions/network_exception.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import 'auth_token_store.dart';
import 'session_role_store.dart';

class AuthApiService {
  final ApiClient _client;
  final AuthTokenStore _tokenStore;
  final SessionRoleStore _roleStore;

  // ✅ build4all base URL
  static const String _MunicipalityBaseUrl =
      'https://unlivable-unison-password.ngrok-free.dev';

  AuthApiService({
    ApiClient? client,
    AuthTokenStore? tokenStore,
    SessionRoleStore? roleStore,
  })  : _client = client ?? ApiClient(),
        _tokenStore = tokenStore ?? AuthTokenStore(),
        _roleStore = roleStore ?? SessionRoleStore();
        




  // ============================================================
  // BALADIYATI — Register
  // POST /auth/users/register
  // ============================================================
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required int municipalityId,
  }) async {
    try {
      final data = await _client.post(
        '/auth/users/register',
        body: {
          'email': email,
          'passwordHash': password,
          'fullName': fullName,
          'phone': phone,
          'role': role,
          'municipality': {'id': municipalityId},
        },
      );

      final response = AuthResponseModel.fromJson(data);

      if (response.token.isNotEmpty) {
        await _tokenStore.saveToken(response.token);
        await _client.saveToken(response.token);
      }

      return response;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to register user', original: e);
    }
  }
  

  // ============================================================
  // BALADIYATI — Login
  // POST /auth/users/login
  // ============================================================
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _client.post(
        '/auth/users/login',
        body: {
          'email': email,
          'passwordHash': password,
        },
      );

      final response = AuthResponseModel.fromJson(data);

      if (response.token.isNotEmpty) {
        await _tokenStore.saveToken(response.token);
        await _client.saveToken(response.token);
      }

      return response;
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to login user', original: e);
    }
  }
  // ============================================================
  // BALADIYATI — Logout
  // POST /auth/logout
  // ============================================================
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', requiresAuth: true);
    } catch (_) {}
    await _tokenStore.clearToken();
    await _client.clearToken();
    await _roleStore.clearRole();
  }

  // refresh token 


  // ============================================================
  // BALADIYATI — Forgot password
  // POST /auth/forgot-password
  // ============================================================
  //   Future<String> forgetPassword({
  //   required String email,
  // }) async {
  //   try {
  //     final response = await _client.post(
  //       '/auth/forgot-password',
  //       body: {'email': email},
  //     );

  //     return response.toString();
  //   } on AppException {
  //     rethrow;
  //   } catch (e) {
  //     throw AppException('Failed to request password reset', original: e);
  //   }
  // }


  // ============================================================
  // BALADIYATI — Reset password
  // POST /auth/reset-password
  // ============================================================
   Future<String> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.post(
        '/auth/reset-password',
        body: {
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      return response.toString();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to reset password', original: e);
    }
  }

  // ============================================================
  // BALADIYATI — Complete profile
  // POST /auth/complete-profile
  // ============================================================

  Future<AuthResponseModel> completeProfileNew({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required int municipalityId,
    required String address,
    required String username,
  }) async {
    try {
      final data = await _client.post(
        '/api/auth/complete-profile',
        body: {
          'email': email,
          'passwordHash': password,
          'fullName': fullName,
          'phone': phone,
          'role': role,
          'municipality': {'id': municipalityId},
          'address': address,
          'username': username,
        },
      );

      final response = AuthResponseModel.fromJson(data);

      if (response.token.isNotEmpty) {
        await _tokenStore.saveToken(response.token);
        await _client.saveToken(response.token);
      }

      return response;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to complete profile', original: e);
    }
  }

    Future<String> completeProfile({
    required String address,
    required String username,
    required int municipalityId,
  }) async {
    try {
      final token = await _tokenStore.getToken();

      if (token != null && token.isNotEmpty) {
        await _client.saveToken(token);
      }

      final response = await _client.post(
        '/auth/complete-profile',
        body: {
          'address': address,
          'username': username,
          'municipality': {'id': municipalityId},
        },
        requiresAuth: true,
      );

      return response['message'] ?? 'Success';
    } on AppException {
      rethrow;
     } //catch (e) {
    //   throw AppException('Failed to complete profile', original: e);
    // }
  }
  // ============================================================
  // TOKEN HELPERS
  // ============================================================
  Future<String?> getSavedToken() => _tokenStore.getToken();
  Future<bool> hasToken() => _tokenStore.hasToken();
}
