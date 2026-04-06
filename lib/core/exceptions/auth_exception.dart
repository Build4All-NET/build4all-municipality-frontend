// lib/core/exceptions/auth_exception.dart
// ─────────────────────────────────────────
// Auth-specific exceptions
// Maps backend error codes to user messages
// ─────────────────────────────────────────

import 'app_exception.dart';

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.original});

  // Factory constructors for common auth errors
  factory AuthException.invalidCredentials() =>
      const AuthException('Invalid email or password',
          code: 'INVALID_CREDENTIALS');

  factory AuthException.userNotFound() =>
      const AuthException('No account found with this email',
          code: 'USER_NOT_FOUND');

  factory AuthException.accountNotVerified() =>
      const AuthException('Please verify your email before logging in',
          code: 'ACCOUNT_NOT_VERIFIED');

  factory AuthException.emailAlreadyExists() =>
      const AuthException('This email is already registered',
          code: 'EMAIL_ALREADY_EXISTS');
}
