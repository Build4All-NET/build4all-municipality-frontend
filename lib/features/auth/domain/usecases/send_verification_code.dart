// lib/features/auth/domain/usecases/send_verification_email.dart
import 'package:baladiyati/features/auth/domain/repository/auth_repository.dart';

import 'package:dartz/dartz.dart';

class SendVerificationCode {
  final AuthRepository repo;
  SendVerificationCode(this.repo);

  Future<Either<AuthFailure, void>> call({
    String? email,
    required String password,
    required int ownerProjectLinkId,
  }) {
    return repo.sendVerificationCode(
      email: email,
      password: password,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}