// lib/features/auth/data/services/auth_api_service.dart

import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import 'auth_token_store.dart';
import 'session_role_store.dart';

class AuthApiService {
  final ApiClient _client;
  final AuthTokenStore _tokenStore;
  final SessionRoleStore _roleStore;

  // ✅ build4all base URL
  static const String _build4allBaseUrl =
      'https://static-sneeze-unfrozen.ngrok-free.dev';

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
  }

  // ============================================================
  // BALADIYATI — Login
  // POST /auth/users/login
  // ============================================================
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
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
  Future<String> forgetPassword({required String email}) async {
    final response = await _client.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    return response.toString();
  }

  // ============================================================
  // BALADIYATI — Reset password
  // POST /auth/reset-password
  // ============================================================
  Future<String> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client.post(
      '/auth/reset-password',
      body: {
        'email': email,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return response.toString();
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

  final data = await _client.post(
    '/api/auth/complete-profile',
    body: {
      'email': email,
      'passwordHash': password,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'municipality': {
        'id': municipalityId,
      },
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
}


  Future<String> completeProfile({
    required String address,
    required String username,
    required int municipalityId,
  }) async {
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
  }
     
  // ============================================================
  // TOKEN HELPERS
  // ============================================================
  Future<String?> getSavedToken() => _tokenStore.getToken();
  Future<bool> hasToken() => _tokenStore.hasToken();
}
