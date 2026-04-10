// lib/features/auth/data/services/auth_api_service.dart

import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import 'auth_token_store.dart';
import 'session_role_store.dart';

class AuthApiService {
  final ApiClient _client;
  final AuthTokenStore _tokenStore;
  final SessionRoleStore _roleStore;

  AuthApiService({
    ApiClient? client,
    AuthTokenStore? tokenStore,
    SessionRoleStore? roleStore,
  })  : _client = client ?? ApiClient(),
        _tokenStore = tokenStore ?? AuthTokenStore(),
        _roleStore = roleStore ?? SessionRoleStore();

  // ─────────────────────────────────────────────────
  // STEP 1 — Send verification email
  // POST /auth/send-verification-email
  // Body: { "email": "..." }
  // ─────────────────────────────────────────────────
  Future<void> sendVerificationEmail({required String email}) async {
    await _client.post(
      '/auth/send-verification-email',
      body: {'email': email},
    );
  }

  // ─────────────────────────────────────────────────
  // STEP 2 — Verify OTP code
  // POST /auth/verify
  // Body: { "code": "123456" }
  // ─────────────────────────────────────────────────
  Future<void> verifyEmailCode({required String code}) async {
    await _client.post(
      '/auth/verify',
      body: {'code': code},
    );
  }

  // ─────────────────────────────────────────────────
  // STEP 3 — Register
  // POST /auth/users/register
  // Body: { email, passwordHash, fullName, phone, role, municipality:{id} }
  // ─────────────────────────────────────────────────
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required int municipalityId,
  }) async {
    final data = await _client.post(
      '/auth/users/register',  // ✅ correct URL with /
      body: {
        'email': email,
        'passwordHash': password,
        'fullName': fullName,       // ✅ correct field name
        'phone': phone,
        'role': role,
        'municipality': {'id': municipalityId}, // ✅ correct format
      },
    );

    final response = AuthResponseModel.fromJson(data);
    await _tokenStore.saveToken(response.token);
    return response;
  }

  // ─────────────────────────────────────────────────
  // LOGIN
  // POST /auth/users/login
  // ─────────────────────────────────────────────────
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
    await _tokenStore.saveToken(response.token);
    return response;
  }

  // ─────────────────────────────────────────────────
  // LOGOUT
  // POST /auth/logout
  // ─────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', requiresAuth: true);
    } catch (_) {}
    await _tokenStore.clearToken();
    await _roleStore.clearRole();
  }

  // ─────────────────────────────────────────────────
  // COMPLETE PROFILE
  // POST /auth/complete-profile
  // ─────────────────────────────────────────────────
  Future<void> completeProfile({
    required String address,
    required String username,
  }) async {
    await _client.post(
      '/auth/complete-profile',
      body: {
        'address': address,
        'userName': username,
      },
      requiresAuth: true,
    );
  }

  // ─────────────────────────────────────────────────
  // FORGOT PASSWORD
  // POST /auth/forgot-password
  // ─────────────────────────────────────────────────
  Future<String> forgetPassword({required String email}) async {
    final response = await _client.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    return response.toString();
  }

  // ─────────────────────────────────────────────────
  // VERIFY RESET CODE
  // POST /auth/verify-code
  // ─────────────────────────────────────────────────
  Future<void> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    await _client.post(
      '/auth/verify-code',
      body: {'email': email, 'code': code},
    );
  }

  // ─────────────────────────────────────────────────
  // RESET PASSWORD
  // POST /auth/reset-password
  // ─────────────────────────────────────────────────
  Future<String> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client.post(
      '/auth/reset-password',
      body: {
        'email': email,
        'password': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return response.toString();
  }

  // ─────────────────────────────────────────────────
  // TOKEN HELPERS
  // ─────────────────────────────────────────────────
  Future<String?> getSavedToken() => _tokenStore.getToken();
  Future<bool> hasToken() => _tokenStore.hasToken();
}
