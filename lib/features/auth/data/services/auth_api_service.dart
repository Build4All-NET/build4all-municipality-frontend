// lib/features/auth/data/services/auth_api_service.dart

import '../../../../core/network/api_client.dart';
//import '../../../../core/exceptions/app_exception.dart';
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

  /// LOGIN
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

  /// LOGOUT
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout', requiresAuth: true);
    } catch (_) {}
    await _tokenStore.clearToken();
    await _roleStore.clearRole();
  }

  /// COMPLETE PROFILE
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
  
  /// TOKEN HELPERS
  Future<String?> getSavedToken() => _tokenStore.getToken();
  Future<bool> hasToken() => _tokenStore.hasToken();
    
  Future<void> sendVerificationEmail({required String email}) async {}

  Future<void> verifyEmailCode({required String code}) async {}
  
  Future<Object?> register({required String email, required String password, required String fullName, /*required String phone*/ required String role, required int municipalityId}) async {}
  
   
}