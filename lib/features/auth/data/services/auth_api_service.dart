// lib/features/auth/data/services/auth_api_service.dart
// ─────────────────────────────────────────
// All HTTP calls to Spring Boot backend
// Endpoints: login, register, verify, logout
// ─────────────────────────────────────────

import '../../../../core/network/api_client.dart';
import '../../../../core/exceptions/app_exception.dart';
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

  // ─────────────────────────────────────────
  // LOGIN — POST /auth/users/login
  // ─────────────────────────────────────────
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
    await _tokenStore.saveToken(response.token);
    return response;
  }

  // ─────────────────────────────────────────
  // REGISTER — POST /auth/users/register
  // ─────────────────────────────────────────
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

    return AuthResponseModel.fromJson(data);
  }

  // ─────────────────────────────────────────
  // SEND VERIFICATION EMAIL
  // POST /auth/send-verification-email
  // ─────────────────────────────────────────
  Future<void> sendVerificationEmail({required String email}) async {
    await _client.post(
      '/auth/send-verification-email',
      body: {'email': email},
    );
  }

  // ─────────────────────────────────────────
  // VERIFY EMAIL CODE — POST /auth/verify
  // ─────────────────────────────────────────
  Future<void> verifyEmailCode({required String code}) async {
    await _client.post(
      '/auth/verify',
      body: {'code': code},
    );
  }

  // ─────────────────────────────────────────
  // LOGOUT — POST /auth/logout
  // ─────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', requiresAuth: true);
    } catch (_) {}
    await _tokenStore.clearToken();
    await _roleStore.clearRole();
  }

  // ─────────────────────────────────────────
  // COMPLETE PROFILE
  // POST /auth/complete-profile
  // ─────────────────────────────────────────
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

  // Token helpers
  Future<String?> getSavedToken() => _tokenStore.getToken();
  Future<bool> hasToken() => _tokenStore.hasToken();
}
