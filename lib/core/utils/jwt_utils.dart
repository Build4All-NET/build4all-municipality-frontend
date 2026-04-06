// lib/core/utils/jwt_utils.dart
// ─────────────────────────────────────────
// Read information from JWT token
// Without calling the server!
// ─────────────────────────────────────────

import 'package:jwt_decoder/jwt_decoder.dart';

class JwtUtils {
  // Check if token is expired
  static bool isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }

  // Get email from token
  static String? getEmail(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['sub'] ?? decoded['email'];
    } catch (_) {
      return null;
    }
  }

  // Get role from token
  static String? getRole(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['role'];
    } catch (_) {
      return null;
    }
  }

  // Get municipality id from token
  static int? getMunicipalityId(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['municipalityId'];
    } catch (_) {
      return null;
    }
  }

  // Get all decoded data
  static Map<String, dynamic>? decode(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (_) {
      return null;
    }
  }
}
