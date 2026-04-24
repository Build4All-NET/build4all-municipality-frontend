import '../entities/forgot_password_entity.dart';
import '../repositories/forgot_password_repository.dart';

class VerifyResetCode {
  final ForgotPasswordRepository repo;
  VerifyResetCode(this.repo);

  Future<ForgotPasswordResult> call({
    required String email,
    required String code,
    required int ownerProjectLinkId,
  }) {
    return repo.verifyResetCode(
      email: email,
      code: code,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}
