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
  // ─────────────────────────────────────────────────
  Future<void> sendVerificationEmail({required String email}) async {
    await _client.post(
      '/auth/send-verification-email',
      body: {'email': email},
    );
  }

  // ─────────────────────────────────────────────────
  // STEP 2 — Verify OTP code
  // ─────────────────────────────────────────────────
 Future<void> verifyEmailCode({
  required String email,
  required String code,
}) async {
  await _client.post(
    '/auth/verify',
    body: {
      'email': email,
      'code': code,
    },
  );
}

  // ─────────────────────────────────────────────────
  // STEP 3 — Register
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

    // Save token to BOTH storages so complete profile can use it
    if (response.token.isNotEmpty) {
      await _tokenStore.saveToken(response.token);
      await _client.saveToken(response.token);
    }

    return response;
  }

  // ─────────────────────────────────────────────────
  // LOGIN
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

    // Save token to BOTH storages
    if (response.token.isNotEmpty) {
      await _tokenStore.saveToken(response.token);
      await _client.saveToken(response.token);
    }

    return response;
  }

  // ─────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', requiresAuth: true);
    } catch (_) {}
    await _tokenStore.clearToken();
    await _client.clearToken();
    await _roleStore.clearRole();
  }

  // ─────────────────────────────────────────────────
  // COMPLETE PROFILE
  // ─────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────
  // FORGOT PASSWORD
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