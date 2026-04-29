import '../entities/forgot_password_entity.dart';

abstract class ForgotPasswordRepository {
  Future<ForgotPasswordResult> sendResetCode({
    required String email,
    required int ownerProjectLinkId,
  });

  Future<ForgotPasswordResult> verifyResetCode({
    required String email,
    required String code,
    required int ownerProjectLinkId,
  });

  Future<ForgotPasswordResult> updatePassword({
    required String email,
    required String code,
    required String newPassword,
    required int ownerProjectLinkId,
  });
}
