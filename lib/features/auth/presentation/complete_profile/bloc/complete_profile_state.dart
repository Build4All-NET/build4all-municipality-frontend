import 'package:equatable/equatable.dart';

class CompleteProfileState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const CompleteProfileState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  static const Object _unset = Object();

  CompleteProfileState copyWith({
    bool? isLoading,
    bool? isSuccess,
    Object? errorMessage = _unset,
  }) {
    return CompleteProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMessage];
}
