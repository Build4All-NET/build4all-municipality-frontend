
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:dio/dio.dart';
import 'app_exception.dart';

class ExceptionMapper {
  static String toMessage(Object error) {
    try {
      if (error is String) return _sanitize(error);

      if (error is AppException) {
        final orig = error.original;
        if (orig != null && orig is! AppException) {
          final msgFromOrig = toMessage(orig);
          if (msgFromOrig.trim().isNotEmpty) return msgFromOrig;
        }

        switch (error.code) {
          case 'INVALID_CREDENTIALS':
            return 'Invalid email or password';
          case 'WRONG_PASSWORD':
            return 'Invalid email or password';
          case 'USER_NOT_FOUND':
            return 'User not found';
          case 'INVALID_EMAIL_FORMAT':
            return 'Invalid email format';
          case 'LOGIN_LOCKED':
          // Message already contains context (e.g. lock duration) → use as-is
            return _sanitize(error.message);
          case 'INACTIVE':
            return 'Your account is inactive. Reactivate to continue.';
          case 'NETWORK_ERROR':
            return 'No internet connection';
          case 'SERVER_ERROR':
            return 'Server error. Please try later.';
        }

        return _sanitize(error.message);
      }
      if (error is DioException) return _dioToMessage(error);

      // Standard Dart errors
      if (error is FormatException) return 'Invalid server response.';
      if (error is ArgumentError) return 'Invalid input.';
      if (error is TypeError) return 'Something went wrong. Please try again.';

      //  fallback
      return _sanitize(error.toString());
    } catch (_) {
      // Safety net — mapper must never crash the UI
      return 'Something went wrong. Please try again.';
    }
  }

 
  static String _dioToMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';
      case DioExceptionType.unknown:
        return 'Network error. Check your connection.';
      case DioExceptionType.badResponse:
        break; // handled below
    }

    // HTTP errors: try to extract a message from the backend JSON body first
    final data = e.response?.data;
     final status = e.response?.statusCode;    final extracted = _extractBackendMessage(data);
    if (extracted != null && extracted.trim().isNotEmpty) {
      return _sanitize(extracted);
    }
    return _statusFallback(e.response?.statusCode);
  }

  /// Returns a generic message based on HTTP status code.
  static String _statusFallback(int? status) {
    if (status == null) return 'Request failed.';
    switch (status) {
      case 400:
      case 422:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You don\'t have permission to do this.';
      case 404:
        return 'Not found.';
      case 409:
        return 'Conflict. This already exists or can\'t be done now.';
      default:
        if (status >= 500) return 'Server error. Please try later.';
        return 'Request failed.';
    }
  }

  
  static String? _extractBackendMessage(dynamic data) {
    if (data == null) return null;

    // Backend returned a plain string (sometimes JSON-encoded)
    if (data is String) {
      final s = data.trim();
      // Try to parse it as JSON first
      if ((s.startsWith('{') && s.endsWith('}')) ||
          (s.startsWith('[') && s.endsWith(']'))) {
        try {
          return _extractBackendMessage(json.decode(s));
        } catch (_) {
          return s; // return the raw string
        }
      }
      return s;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

    for (final k in ['error', 'message', 'detail', 'msg', 'title']) {
        final v = map[k];
        if (v is String && v.trim().isNotEmpty) return v;
      }

      final errs = map['errors'];
      if (errs is Map) {
        final parts = <String>[];
        errs.forEach((_, val) {
          if (val is List) {
            for (final x in val) {
              if (x is String && x.trim().isNotEmpty) parts.add(x);
            }
          } else if (val is String && val.trim().isNotEmpty) {
            parts.add(val);
          }
        });
        if (parts.isNotEmpty) return parts.join(', ');
      }
    }

    return null;
  }

  static String _sanitize(String raw) {
    var msg = raw.trim();

    // Strip Dart/Dio exception prefixes that leak into toString()
    msg = msg.replaceAll(RegExp(r'^(Exception:)\s*'), '');
    msg = msg.replaceAll(RegExp(r'^(DioException:)\s*'), '');
    msg = msg.replaceAll(RegExp(r'^(Bad state:)\s*'), '');

    // If the full Dio dump was somehow stringified, keep only the first line
    if (msg.contains('requestOptions') || msg.contains('Response:')) {
      msg = msg.split('\n').first.trim();
    }

    // Cap at 160 chars to prevent overflow in toast/UI
    const maxLen = 160;
    if (msg.length > maxLen) msg = '${msg.substring(0, maxLen)}…';

    return msg.isEmpty ? 'Something went wrong.' : msg;
  }
}