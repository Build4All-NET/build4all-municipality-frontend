// lib/features/auth/presentation/register/bloc/register_bloc.dart
import 'package:baladiyati/features/auth/domain/repository/auth_repository.dart';
import 'package:baladiyati/features/auth/presentation/register/bloc/register_Event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:baladiyati/features/auth/domain/usecases/send_verification_code.dart';
//import 'register_event.dart' hide RegisterEvent, RegisterSendCodeSubmitted;
import 'register_state.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SendVerificationCode sendVerificationCode;

  RegisterBloc({required this.sendVerificationCode})
      : super(RegisterState.initial()) {
    on<RegisterSendCodeSubmitted>(_onSendCodeSubmitted);
  }

  Future<void> _onSendCodeSubmitted(
      RegisterSendCodeSubmitted event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      errorCode: null,
      codeSent: false,
      contact: null,
      resumeCompleteProfile: false,
      resumePendingId: null,
    ));

    try {
      final Either<AuthFailure, void> result = await sendVerificationCode(
        email: event.email.trim(),
        password: event.password,
        ownerProjectLinkId: 2, // عدل حسب Env أو id المشروع
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            isLoading: false,
            errorCode: failure.code ?? 'GENERIC',
            codeSent: false,
            contact: event.email,
            resumeCompleteProfile:
                failure.code == 'PENDING_ALREADY_VERIFIED',
            resumePendingId: failure.pendingId,
          ));
        },
        (_) {
          emit(state.copyWith(
            isLoading: false,
            errorCode: null,
            codeSent: true,
            contact: event.email,
            resumeCompleteProfile: false,
            resumePendingId: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorCode: 'GENERIC',
        codeSent: false,
        contact: null,
        resumeCompleteProfile: false,
        resumePendingId: null,
      ));
    }
  }
}