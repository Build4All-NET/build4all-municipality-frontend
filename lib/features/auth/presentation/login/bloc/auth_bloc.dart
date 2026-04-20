// lib/features/auth/presentation/login/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/auth_api_service.dart';
import '../../../data/services/session_role_store.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../../../core/exceptions/exception_mapper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService authApi  ;
  final SessionRoleStore _roleStore = SessionRoleStore();

  AuthBloc({required this.authApi}) : super(AuthState.initial()) {
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthUserPatched>(_onUserPatched);
  }

  /// 🔹 LOGIN (CITIZEN / EMPLOYEE)
  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await authApi.login(
        email: event.email.trim(),
        password: event.password
      );

      // Sauvegarde rôle

      // Création user temporaire (pas de userId dans AuthResponseModel)
      final user = UserEntity(
        id: 0, // valeur temporaire
        email: event.email.trim(),
      );

      emit(state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        user: user,
        token: response.token,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ExceptionMapper.toMessage(e),
      ));
    }
  }

  /// 🔹 LOGOUT
  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authApi.logout(); // ← plus de paramètres inutiles
    } catch (_) {}

    emit(AuthState.initial());
  }

  /// 🔹 UPDATE USER
  void _onUserPatched(
    AuthUserPatched event,
    Emitter<AuthState> emit,
  ) {
    final current = state.user;
    if (!state.isLoggedIn || current == null) return;

    emit(state.copyWith(
      user: current.copyWith(
        fullName: event.fullName,
        username: event.username,
        avatarUrl: event.avatarUrl,
        address: event.address,
        status: event.status,
      ),
    ));
  }
}