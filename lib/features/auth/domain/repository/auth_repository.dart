// lib/features/auth/domain/repository/auth_repository.dart
// ─────────────────────────────────────────
// Abstract interface — defines what auth can do
// The implementation is in data/repository/
// ─────────────────────────────────────────

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<String>login({
    required String email,
    required String password,
  });

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
   // required String phone,
    required String role,
    required int municipalityId,
  });

  Future<void> sendVerificationEmail({required String email});

  Future<void> verifyEmailCode({required String code});

  Future<void> logout();

  Future<void> completeProfile({
    required String address,
    required String username,
  });

  Future<String?> getSavedToken();
}
