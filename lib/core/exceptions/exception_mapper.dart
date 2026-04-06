// lib/core/exceptions/exception_mapper.dart
// ─────────────────────────────────────────
// Converts any error to a user-friendly message
// Used in BLoC to show error in snackbar
// ─────────────────────────────────────────

import 'app_exception.dart';

class ExceptionMapper {
  static String toMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    final msg = error.toString().replaceAll('Exception: ', '');

    // Map backend error codes
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
    if (msg.contains('MISSING_FIELDS')) {
      return 'Please fill all required fields';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Cannot connect to server. Check your connection.';
    }

    return 'Something went wrong. Please try again.';
  }
}
