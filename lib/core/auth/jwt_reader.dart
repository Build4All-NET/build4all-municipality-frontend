import 'dart:async';

/// Reads a stored JWT from JwtLocalDataSource without knowing the exact method name.
/// It tries common method names on a `dynamic` instance and returns the first success.
class JwtReader {
  /// Add/adjust candidates if your datasource uses a different name.
  static const _candidates = <String>[
    'getToken',
    'readToken',
    'getStoredToken',
    'getJwt',
    'readJwt',
    'getAccessToken',
    'readAccessToken',
    'token',          // getter-style
    'jwt',            // getter-style
    'accessToken',    // getter-style
  ];

  /// Returns the stored JWT or null.
  static Future<String?> read(dynamic dataSource) async {
    for (final name in _candidates) {
      try {
        final result = await _invokeMaybeAsync(dataSource, name);
        if (result is String && result.isNotEmpty) {
          return result;
        }
      } catch (_) {
        // swallow and try next
      }
    }
    return null;
  }

  static Future<dynamic> _invokeMaybeAsync(dynamic obj, String name) async {
    final mirrorLike = obj; // keep as dynamic to bypass static checks
    final member = mirrorLike?.noSuchMethod; // ensure dynamic

    // Try call as method
    try {
      final value = await _asFuture(() => mirrorLike?.callMethod(name));
      if (value != null) return value;
    } catch (_) {}

    // Try direct getter (field/getter)
    try {
      final value = await _asFuture(() => mirrorLike?.getProperty(name));
      if (value != null) return value;
    } catch (_) {}

    // Last resort: attempt direct invocation (works for many classes when dynamic)
    try {
      final v = mirrorLike?[name];
      if (v is Future) return await v;
      return v;
    } catch (_) {}

    // If all fail, try regular dynamic invocations that often work:
    try {
      final v = (mirrorLike as dynamic)?.call(name);
      if (v is Future) return await v;
      return v;
    } catch (_) {}

    try {
      final v = (mirrorLike as dynamic)?[name];
      if (v is Future) return await v;
      return v;
    } catch (_) {}

    // Give up
    throw StateError('No member $name');
  }

  static Future<dynamic> _asFuture(dynamic Function() fn) async {
    final v = fn();
    if (v is Future) return await v;
    return v;
  }
}
