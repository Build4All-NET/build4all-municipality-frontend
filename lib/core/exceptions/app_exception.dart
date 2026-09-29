// lib/core/exceptions/app_exception.dart
// ─────────────────────────────────────────
// Base exception class for the whole app
// All errors go through this
// ─────────────────────────────────────────

class AppException implements Exception {
  final String message;
  final String? code;
  final Object? original;

  const AppException(this.message, {this.code, this.original});

  /// Many screens show `error.toString()` directly, so this returns only the
  /// user-facing (localized) message, without a technical prefix.
  @override
  String toString() => message;
}
