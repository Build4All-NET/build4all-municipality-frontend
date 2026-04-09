// lib/features/auth/data/repository/auth_repository_impl.dart
import 'package:baladiyati/features/auth/domain/repository/auth_repository.dart';

import 'package:baladiyati/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<AuthFailure, void>> sendVerificationCode({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    // TODO: implémentation API réelle
    return const Right(null);
  }

  @override
  Future<Either<AuthFailure, void>> sendVerificationEmail({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    // TODO: implémentation API réelle
    return const Right(null);
  }

  @override
  Future<Either<AuthFailure, int>> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    // TODO: implémentation API réelle
    return const Right(1);
  }

  @override
  Future<Either<AuthFailure, int>> verifyPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    return const Right(1);
  }

  @override
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    return UserEntity(id: 1, username: 'demo', email: email);
  }

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
    return UserEntity(id: pendingId, username: username, email: '$username@email.com');
  }
}