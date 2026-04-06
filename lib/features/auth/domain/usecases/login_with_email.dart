// lib/features/auth/domain/usecases/login_with_email.dart
// ─────────────────────────────────────────
// UseCase: Login with email and password
// Calls the repository
// ─────────────────────────────────────────

import '../repository/auth_repository.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<String> call({
    required String email,
    required String password,
  }) {
    return repository.login(
      email: email,
      password: password,
    );
  }
}
