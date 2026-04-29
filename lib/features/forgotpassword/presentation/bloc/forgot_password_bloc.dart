import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_reset_code.dart';
import '../../domain/usecases/verify_reset_code.dart';
import '../../domain/usecases/update_password.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final SendResetCode sendResetCode;
  final VerifyResetCode verifyResetCode;
  final UpdatePassword updatePassword;

  ForgotPasswordBloc({
    required this.sendResetCode,
    required this.verifyResetCode,
    required this.updatePassword,
  }) : super(ForgotPasswordState.initial()) {
    on<ForgotSendCodePressed>(_onSend);
    on<ForgotVerifyCodePressed>(_onVerify);
    on<ForgotUpdatePasswordPressed>(_onUpdate);
    on<ForgotClearMessage>(
      (e, emit) => emit(state.copyWith(clearSuccess: true, clearError: true)),
    );
  }

  Future<void> _onSend(
    ForgotSendCodePressed e,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      final res = await sendResetCode(
        email: e.email,
        ownerProjectLinkId: e.ownerProjectLinkId,
      );
      emit(state.copyWith(isLoading: false, successMessage: res.message));
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err));
    }
  }

  Future<void> _onVerify(
    ForgotVerifyCodePressed e,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      final res = await verifyResetCode(
        email: e.email,
        code: e.code,
        ownerProjectLinkId: e.ownerProjectLinkId,
      );
      emit(state.copyWith(isLoading: false, successMessage: res.message));
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err));
    }
  }

  Future<void> _onUpdate(
    ForgotUpdatePasswordPressed e,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      final res = await updatePassword(
        email: e.email,
        code: e.code,
        newPassword: e.newPassword,
        ownerProjectLinkId: e.ownerProjectLinkId,
      );
      emit(state.copyWith(isLoading: false, successMessage: res.message));
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err));
    }
  }
}
