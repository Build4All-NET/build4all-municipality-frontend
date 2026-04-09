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

  @override
  String toString() => 'AppException($code): $message';
}
