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
  // ✅ BUILD4ALL — Send verification
  // POST https://build4all.../api/auth/send-verification
  // ============================================================
  Future<void> sendVerificationBuild4All({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    await _client.postToUrl(
      '$_build4allBaseUrl/api/auth/send-verification',
      body: {
        'email': email,
        'password': password,
        'ownerProjectLinkId': ownerProjectLinkId,
      },
    );
  }

  // ============================================================
  // ✅ BUILD4ALL — Verify OTP code
  // POST https://build4all.../api/auth/verify-email-code
  // Returns pendingId (userId) needed for complete-profile
  // ============================================================
  Future<int> verifyEmailCodeBuild4All({
    required String email,
    required String code,
  }) async {
    final response = await _client.postToUrl(
      '$_build4allBaseUrl/api/auth/verify-email-code',
      body: {
        'email': email,
        'code': code,
      },
    );
    return response['user']['id'] as int;
  }

  // ============================================================
  // BALADIYATI — Send verification email
  // POST /auth/send-verification-email
  // ============================================================
  Future<void> sendVerificationEmail({required String email}) async {
    await _client.post(
      '/auth/send-verification-email',
      body: {'email': email},
    );
  }

  // ============================================================
  // BALADIYATI — Verify OTP code
  // POST /auth/verify
  // ============================================================
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    await _client.post(
      '/auth/verify',
      body: {'email': email, 'code': code},
    );
  }

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
    required String role,
  }) async {
    final data = await _client.post(
      '/auth/users/login',
      body: {
        'email': email,
        'passwordHash': password,
        'role': role,
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
