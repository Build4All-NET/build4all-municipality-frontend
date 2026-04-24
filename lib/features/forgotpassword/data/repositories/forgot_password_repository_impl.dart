import '../../domain/entities/forgot_password_entity.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import '../services/forgot_password_api_service.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final ForgotPasswordApiService api;

  ForgotPasswordRepositoryImpl({required this.api});

  @override
  Future<ForgotPasswordResult> sendResetCode({
    required String email,
    required int ownerProjectLinkId,
  }) async {
    final res = await api.sendResetCode(
      email: email,
      ownerProjectLinkId: ownerProjectLinkId,
    );
    return ForgotPasswordResult(message: res.message);
  }

  @override
  Future<ForgotPasswordResult> verifyResetCode({
    required String email,
    required String code,
    required int ownerProjectLinkId,
  }) async {
    final res = await api.verifyResetCode(
      email: email,
      code: code,
      ownerProjectLinkId: ownerProjectLinkId,
    );
    return ForgotPasswordResult(message: res.message);
  }

  @override
  Future<ForgotPasswordResult> updatePassword({
    required String email,
    required String code,
    required String newPassword,
    required int ownerProjectLinkId,
  }) async {
    final res = await api.updatePassword(
      email: email,
      code: code,
      newPassword: newPassword,
      ownerProjectLinkId: ownerProjectLinkId
    );
    return ForgotPasswordResult(message: res.message);
  }
}
