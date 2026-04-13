// lib/core/exceptions/exception_mapper.dart

import 'app_exception.dart';

class ExceptionMapper {
  static String toMessage(Object error) {
    // If it's already an AppException, use its message directly
    if (error is AppException) {
      return error.message;
    }

    final msg = error.toString().replaceAll('Exception: ', '');

    // ── Auth errors ───────────────────────────────
    if (msg.contains('INVALID_CREDENTIALS')) {
      return 'Invalid email or password';
    }
    if (msg.contains('USER_NOT_FOUND')) {
      return 'No account found with this email';
    }
    if (msg.contains('ACCOUNT_NOT_VERIFIED')) {
      return 'Please verify your email before logging in';
    }
    if (msg.contains('EMAIL_ALREADY_EXISTS')) {
      return 'This email is already registered';
    }
    if (msg.contains('MISSING_FIELDS') || msg.contains('MISSING_CREDENTIALS')) {
      return 'Please fill all required fields';
    }

    // ── Reset password errors ─────────────────────
    if (msg.contains('INVALID_CODE')) {
      return 'The verification code is incorrect';
    }
    if (msg.contains('CODE_EXPIRED')) {
      return 'The verification code has expired. Please request a new one.';
    }
    if (msg.contains('PASSWORDS_MISMATCH')) {
      return 'Passwords do not match';
    }
    if (msg.contains('WEAK_PASSWORD')) {
      return 'Password must be at least 6 characters';
    }
    if (msg.contains('MISSING_EMAIL')) {
      return 'Email is required';
    }
    if (msg.contains('INVALID_FORMAT')) {
      return 'Invalid format. Please check your input.';
    }

    // ── Network errors ────────────────────────────
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Cannot connect to server. Check your connection.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
