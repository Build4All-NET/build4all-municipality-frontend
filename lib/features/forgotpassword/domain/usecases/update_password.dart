import '../entities/forgot_password_entity.dart';
import '../repositories/forgot_password_repository.dart';

class UpdatePassword {
  final ForgotPasswordRepository repo;
  UpdatePassword(this.repo);

  Future<ForgotPasswordResult> call({
    required String email,
    required String code,
    required String newPassword,
    required int ownerProjectLinkId,
  }) {
    return repo.updatePassword(
      email: email,
      code: code,
      newPassword: newPassword,
      ownerProjectLinkId: ownerProjectLinkId,
    );
  }
}
