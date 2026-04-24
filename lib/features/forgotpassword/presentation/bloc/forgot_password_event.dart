import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ForgotSendCodePressed extends ForgotPasswordEvent {
  final String email;
  final int ownerProjectLinkId;
  const ForgotSendCodePressed({
    required this.email,
    required this.ownerProjectLinkId,
  });

  @override
  List<Object?> get props => [email, ownerProjectLinkId];
}

class ForgotVerifyCodePressed extends ForgotPasswordEvent {
  final String email;
  final String code;
  final int ownerProjectLinkId;
  const ForgotVerifyCodePressed({
    required this.email,
    required this.code,
    required this.ownerProjectLinkId,
  });

  @override
  List<Object?> get props => [email, code, ownerProjectLinkId];
}

class ForgotUpdatePasswordPressed extends ForgotPasswordEvent {
  final String email;
  final String code;
  final String newPassword;
  final int ownerProjectLinkId;

  const ForgotUpdatePasswordPressed({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.ownerProjectLinkId,
  });

  @override
  List<Object?> get props => [email, code, newPassword, ownerProjectLinkId];
}

class ForgotClearMessage extends ForgotPasswordEvent {
  const ForgotClearMessage();
}
