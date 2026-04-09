// lib/features/auth/presentation/login/bloc/auth_state.dart
import '../../../domain/entities/user_entity.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final UserEntity? user;
  final String? token;
  final String? errorMessage;
  final String? role;

  AuthState({
    required this.isLoading,
    required this.isLoggedIn,
    required this.user,
    required this.token,
    required this.errorMessage,
    required this.role,
  });

  factory AuthState.initial() => AuthState(
        isLoading: false,
        isLoggedIn: false,
        user: null,
        token: null,
        errorMessage: null,
        role: null,
      );

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    UserEntity? user,
    String? token,
    String? errorMessage,
    String? role,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
      role: role ?? this.role,
    );
  }
}