// lib/core/auth/jwt_claims.dart
import 'dart:convert';

class JwtClaims {
  static Map<String, dynamic>? decode(String? jwt) {
    if (jwt == null || jwt.isEmpty) return null;
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = _base64UrlDecode(parts[1]);
      final map = json.decode(payload);
      return map is Map<String, dynamic> ? map : null;
    } catch (_) {
      return null;
    }
  }

  static int? extractInt(Map<String, dynamic>? claims, List<String> keys) {
    if (claims == null) return null;
    for (final k in keys) {
      if (!claims.containsKey(k)) continue;
      final v = claims[k];
      if (v == null) continue;
      if (v is int) return v;
      if (v is String) {
        final p = int.tryParse(v);
        if (p != null) return p;
      }
      if (v is num) return v.toInt();
    }
    return null;
  }

  static String _base64UrlDecode(String input) {
    var output = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw const FormatException('Invalid Base64URL padding');
    }
    return utf8.decode(base64.decode(output));
  }
}
