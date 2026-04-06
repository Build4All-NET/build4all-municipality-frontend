// lib/features/auth/data/repository/auth_repository_impl.dart
// ─────────────────────────────────────────
// Implements AuthRepository using AuthApiService
// Bridge between domain and data
// ─────────────────────────────────────────

import '../../domain/repository/auth_repository.dart';
import '../services/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService api;

  AuthRepositoryImpl({required this.api});

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await api.login(email: email, password: password);
    return response.token;
  }

  @override
  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required int municipalityId,
  }) async {
    final response = await api.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: role,
      municipalityId: municipalityId,
    );
    return response.token;
  }

  @override
  Future<void> sendVerificationEmail({required String email}) =>
      api.sendVerificationEmail(email: email);

  @override
  Future<void> verifyEmailCode({required String code}) =>
      api.verifyEmailCode(code: code);

  @override
  Future<void> logout() => api.logout();

  @override
  Future<void> completeProfile({
    required String address,
    required String username,
  }) => api.completeProfile(address: address, username: username);

  @override
  Future<String?> getSavedToken() => api.getSavedToken();
}
