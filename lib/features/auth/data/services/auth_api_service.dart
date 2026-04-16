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

  // ============================================================
  // SEND VERIFICATION EMAIL
  // ============================================================
  
  // OLD: /auth/send-verification-email
  Future<void> sendVerificationEmail({required String email}) async {
    await _client.post(
      '/auth/send-verification-email',
      body: {'email': email},
    );
  }

  // NEW: /api/auth/send-verification
  Future<void> sendVerificationEmailNew({required String email}) async {
    await _client.post(
      '/api/auth/send-verification',
      body: {'email': email},
    );
  }

  // ============================================================
  // VERIFY OTP CODE
  // ============================================================
  
  // OLD: /auth/verify
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    await _client.post(
      '/auth/verify',
      body: {'email': email, 'code': code},
    );
  }

  // NEW: /api/auth/verify-email-code
  Future<void> verifyEmailCodeNew({
    required String email,
    required String code,
  }) async {
    await _client.post(
      '/api/auth/verify-email-code',
      body: {'email': email, 'code': code},
    );
  }

  // ============================================================
  // REGISTER / COMPLETE PROFILE
  // ============================================================
  
  // OLD: /auth/users/register
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

  // NEW: /api/auth/complete-profile (Version 1 - Complete registration)
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
  }

  // NEW: /api/auth/complete-profile (Version 2 - Update existing profile)
  Future<Map<String, dynamic>> completeProfileUpdate({
    required String address,
    required String username,
    required int municipalityId,
  }) async {
    final token = await _tokenStore.getToken();
    if (token != null && token.isNotEmpty) {
      await _client.saveToken(token);
    }
    final response = await _client.post(
      '/api/auth/complete-profile',
      body: {
        'address': address,
        'username': username,
        'municipality': {'id': municipalityId},
      },
      requiresAuth: true,
    );
    return response;
  }

  // ============================================================
  // LOGIN
  // ============================================================
  
  // OLD: /auth/users/login
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

  // NEW: /api/auth/user/login
  Future<AuthResponseModel> loginNew({
    required String email,
    required String password,
    required String role,
  }) async {
    final data = await _client.post(
      '/api/auth/user/login',
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
  // LOGOUT
  // ============================================================
  
  // OLD: /auth/logout
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', requiresAuth: true);
    } catch (_) {}
    await _tokenStore.clearToken();
    await _client.clearToken();
    await _roleStore.clearRole();
  }

  // // NEW: /api/auth/logout
  // Future<void> logoutNew() async {
  //   try {
  //     await _client.post('/api/auth/logout', requiresAuth: true);
  //   } catch (_) {}
  //   await _tokenStore.clearToken();
  //   await _client.clearToken();
  //   await _roleStore.clearRole();
  // }

  // ============================================================
  // FORGOT / RESET PASSWORD
  // ============================================================
  
  // OLD: /auth/forgot-password
  Future<String> forgetPassword({required String email}) async {
    final response = await _client.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    return response.toString();
  }

  // NEW: /api/users/reset-password?ownerProjectLinkId={{ownerProjectLinkId}}
  Future<String> resetPassword({
    required String email,
    required int ownerProjectLinkId,
  }) async {
    final response = await _client.post(
      '/api/users/reset-password?ownerProjectLinkId=$ownerProjectLinkId',
      body: {'email': email},
    );
    return response.toString();
  }

  // ============================================================
  // VERIFY RESET CODE
  // ============================================================
  
  // OLD: /auth/verify-code
  Future<void> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    await _client.post(
      '/auth/verify-code',
      body: {'email': email, 'code': code},
    );
  }

  // NEW: /api/users/verify-reset-code?ownerProjectLinkId={{ownerProjectLinkId}}
  Future<void> verifyResetCode({
    required String email,
    required String code,
    required int ownerProjectLinkId,
  }) async {
    await _client.post(
      '/api/users/verify-reset-code?ownerProjectLinkId=$ownerProjectLinkId',
      body: {'email': email, 'code': code},
    );
  }

  // ============================================================
  // UPDATE PASSWORD
  // ============================================================
  
  // OLD: /auth/reset-password
  Future<String> resetPasswordOld({
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

  // NEW: /api/users/update-password?ownerProjectLinkId={{ownerProjectLinkId}}
  Future<String> updatePassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
    required int ownerProjectLinkId,
  }) async {
    final response = await _client.post(
      '/api/users/update-password?ownerProjectLinkId=$ownerProjectLinkId',
      body: {
        'email': email,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return response.toString();
  }

  // ============================================================
  // COMPLETE PROFILE (Old version - without email/password)
  // ============================================================
  
  // OLD: /auth/complete-profile
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