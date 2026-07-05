import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminTokenStore {
  final FlutterSecureStorage _storage;

  const AdminTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(resetOnError: true),
        );

  static const _keyToken = 'admin_token';
  static const _keyRole = 'admin_role';
  static const _keyRefreshToken = 'admin_refresh_token';
  static const _keyTenantId = 'admin_tenant_id';

  // ===========================
  // DEBUG / BUG SWITCH
  // ===========================

  /// ✅ Turn this ON temporarily to print everything
  static const bool debugLogs = true;

  static const bool simulateBearerBug = false;

  void _log(String msg) {
    if (kDebugMode && debugLogs) {
      debugPrint('🧾 AdminTokenStore | $msg');
    }
  }

  Future<void> _safeWrite({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      _log('write failed for $key: $e');
    }
  }

  Future<String?> _safeRead({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _log('read failed for $key: $e');
      return null;
    }
  }

  Future<void> _safeDelete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      _log('delete failed for $key: $e');
    }
  }

  String _stripBearer(String token) {
    final t = token.trim();
    if (t.toLowerCase().startsWith('bearer ')) return t.substring(7).trim();
    return t;
  }

  String _maybeAddBearerBug(String rawJwt) {
    if (!simulateBearerBug) return rawJwt;
    // inject the classic bug
    return 'Bearer $rawJwt';
  }

  // ===========================
  // SAVE
  // ===========================

  Future<void> save({
    required String token,
    required String role,
    String? refreshToken,
    String? tenantId,
  }) async {
    // ✅ ALWAYS store RAW jwt (no Bearer)
    final rawToken = _stripBearer(token);
    final safeToken = _maybeAddBearerBug(rawToken);

    final safeRole = role.trim();

    _log('SAVE() called');
    _log('token in = "${token.length > 20 ? token.substring(0, 20) : token}"...');
    _log('raw token = "${rawToken.length > 20 ? rawToken.substring(0, 20) : rawToken}"...');
    _log('stored token (after bug toggle) startsWithBearer=${safeToken.toLowerCase().startsWith("bearer ")}');
    _log('role="$safeRole" tenantId="${tenantId ?? ""}" refreshToken="${refreshToken ?? ""}"');

    await _safeWrite(key: _keyToken, value: safeToken);
    await _safeWrite(key: _keyRole, value: safeRole);

    if (refreshToken != null) {
      final v = refreshToken.trim();
      if (v.isEmpty) {
        await _safeDelete(key: _keyRefreshToken);
        _log('refreshToken deleted (empty)');
      } else {
        await _safeWrite(key: _keyRefreshToken, value: v);
        _log('refreshToken saved (len=${v.length})');
      }
    }

    if (tenantId != null) {
      final t = tenantId.trim();
      if (t.isEmpty) {
        await _safeDelete(key: _keyTenantId);
        _log('tenantId deleted (empty)');
      } else {
        await _safeWrite(key: _keyTenantId, value: t);
        _log('tenantId saved="$t"');
      }
    }

    // ✅ sanity check: read after write
    final stored = await getToken();
    _log('after save -> stored token startsWithBearer=${(stored ?? "").toLowerCase().startsWith("bearer ")}');
  }

  // ===========================
  // READ
  // ===========================

  Future<String?> getToken() async {
    final t = await _safeRead(key: _keyToken);
    _log('getToken() -> ${t == null ? "null" : "len=${t.length} startsWithBearer=${t.toLowerCase().startsWith("bearer ")}"}');
    return t;
  }

  Future<String?> getRole() async {
    final r = await _safeRead(key: _keyRole);
    _log('getRole() -> ${r ?? "null"}');
    return r;
  }

  Future<String?> getRefreshToken() async {
    final r = await _safeRead(key: _keyRefreshToken);
    _log('getRefreshToken() -> ${r == null ? "null" : "len=${r.length}"}');
    return r;
  }

  Future<String?> getTenantId() async {
    final t = await _safeRead(key: _keyTenantId);
    _log('getTenantId() -> ${t ?? "null"}');
    return t;
  }

  // ===========================
  // CLEAR
  // ===========================

  Future<void> clear() async {
    _log('CLEAR() called -> deleting token/role/refresh/tenant');
    await _safeDelete(key: _keyToken);
    await _safeDelete(key: _keyRole);
    await _safeDelete(key: _keyRefreshToken);
    await _safeDelete(key: _keyTenantId);

    // verify cleared
    final after = await getToken();
    _log('after clear -> token is ${after == null ? "null ✅" : "NOT NULL ❌"}');
  }

  // ===========================
  // DEBUG DUMP (call from anywhere)
  // ===========================

  Future<void> debugDump() async {
    final tok = await getToken();
    final role = await getRole();
    final ref = await getRefreshToken();
    final ten = await getTenantId();

    _log('--- DEBUG DUMP ---');
    _log('token: ${tok == null ? "null" : "len=${tok.length} startsWithBearer=${tok.toLowerCase().startsWith("bearer ")}"}');
    _log('role: ${role ?? "null"}');
    _log('refresh: ${ref == null ? "null" : "len=${ref.length}"}');
    _log('tenant: ${ten ?? "null"}');
    _log('------------------');
  }
}