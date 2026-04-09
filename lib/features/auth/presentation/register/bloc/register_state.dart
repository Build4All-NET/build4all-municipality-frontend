import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  final bool isLoading;
  final String? errorCode;
  final bool codeSent;
  final String? contact; // email فقط
  final bool resumeCompleteProfile;
  final int? resumePendingId;

  const RegisterState({
    required this.isLoading,
    required this.errorCode,
    required this.codeSent,
    required this.contact,
    required this.resumeCompleteProfile,
    required this.resumePendingId,
  });

  factory RegisterState.initial() {
    return const RegisterState(
      isLoading: false,
      errorCode: null,
      codeSent: false,
      contact: null,
      resumeCompleteProfile: false,
      resumePendingId: null,
    );
  }

  static const Object _unset = Object();

  RegisterState copyWith({
    bool? isLoading,
    Object? errorCode = _unset,
    bool? codeSent,
    Object? contact = _unset,
    bool? resumeCompleteProfile,
    Object? resumePendingId = _unset,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorCode:
          identical(errorCode, _unset) ? this.errorCode : errorCode as String?,
      codeSent: codeSent ?? this.codeSent,
      contact: identical(contact, _unset) ? this.contact : contact as String?,
      resumeCompleteProfile:
          resumeCompleteProfile ?? this.resumeCompleteProfile,
      resumePendingId: identical(resumePendingId, _unset)
          ? this.resumePendingId
          : resumePendingId as int?,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorCode,
        codeSent,
        contact,
        resumeCompleteProfile,
        resumePendingId,
      ];
}