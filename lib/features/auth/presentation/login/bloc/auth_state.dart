// lib/features/auth/presentation/login/bloc/auth_state.dart
import '../../../domain/entities/user_entity.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final UserEntity? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.token,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    UserEntity? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}
