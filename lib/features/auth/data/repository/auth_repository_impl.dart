// lib/features/auth/data/repository/auth_repository_impl.dart
import 'package:baladiyati/features/auth/domain/repository/auth_repository.dart';
import 'package:baladiyati/features/auth/domain/entities/user_entity.dart';
import 'package:baladiyati/features/auth/data/services/auth_api_service.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AuthApiService _api = AuthApiService();

  // ─────────────────────────────────────────────────
  // STEP 1 — Send verification code
  // ✅ Actually calls POST /auth/send-verification-email
  // ─────────────────────────────────────────────────
  @override
  Future<Either<AuthFailure, void>> sendVerificationCode({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      if (email != null && email.isNotEmpty) {
        await _api.sendVerificationEmail(email: email);
      }
      return const Right(null);
    } catch (e) {
      // ✅ Correct constructor: positional message, named code
      return Left(AuthFailure(
        e.toString(),
        code: 'SEND_CODE_FAILED',
      ));
    }
  }

  // ─────────────────────────────────────────────────
  // STEP 2 — Verify OTP code
  // ✅ Actually calls POST /auth/verify
  // ─────────────────────────────────────────────────
 @override
Future<Either<AuthFailure, int>> verifyEmailCode({
  required String email,
  required String code,
}) async {
  try {
    await _api.verifyEmailCode(
      email: email,   // ✅ ADD THIS
      code: code,
    );
    return const Right(1);
  } catch (e) {
    return Left(AuthFailure(
      e.toString(),
      code: 'VERIFY_FAILED',
    ));
  }
}

  // ─────────────────────────────────────────────────
  // Verify phone code (not implemented yet)
  // ─────────────────────────────────────────────────
  @override
  Future<Either<AuthFailure, int>> verifyPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    return const Right(1);
  }

  // ─────────────────────────────────────────────────
  // Login with email
  // ─────────────────────────────────────────────────
  @override
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    final response = await _api.login(
      email: email,
      password: password,
      role: 'CITIZEN',
    );
    return UserEntity(id: 0, username: email, email: email);
  }

  // ─────────────────────────────────────────────────
  // Complete profile
  // ─────────────────────────────────────────────────
  @override
  Future<UserEntity> completeProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    required int ownerProjectLinkId,
    String? profileImagePath,
  }) async {
    await _api.completeProfile(
      address: '',
      username: username,
      municipalityId: 1
    );
    return UserEntity(
      id: pendingId,
      username: username,
      email: '$username@email.com',
    );
  }
}
