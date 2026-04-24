import 'package:equatable/equatable.dart';

class ForgotPasswordState extends Equatable {
  final bool isLoading;
  final String? successMessage;
  final Object? error;

  const ForgotPasswordState({
    required this.isLoading,
    this.successMessage,
    this.error,
  });

  factory ForgotPasswordState.initial() =>
      const ForgotPasswordState(isLoading: false);

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? successMessage,
    Object? error,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, successMessage, error];
}
