
import '../entities/forgot_password_entity.dart';
import '../repositories/forgot_password_repository.dart';

class SendResetCode {
  final ForgotPasswordRepository repo;
  SendResetCode(this.repo);

  Future<ForgotPasswordResult> call({
    required String email,
    required int ownerProjectLinkId,
  }) {
    return repo.sendResetCode(
      email: email,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}
