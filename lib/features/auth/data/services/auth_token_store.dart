import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStore {
  static const _keyToken = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyTenantId = 'auth_tenant_id';
  static const _keyUserJson = 'auth_user_json';
  static const _keyWasInactive = 'was_inactive';

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🧾 AuthTokenStore | $message');
    }
  }

  String _stripBearer(String token) {
    final value = token.trim();

    if (value.toLowerCase().startsWith('bearer ')) {
      return value.substring(7).trim();
    }

    return value;
  }

  Future<void> saveToken({
    required String token,
    String? refreshToken,
    String? tenantId,
    bool wasInactive = false,
    Map<String, dynamic>? userJson,
  }) async {
    final sp = await SharedPreferences.getInstance();

    final cleanToken = _stripBearer(token);

    await sp.setString(_keyToken, cleanToken);
    await sp.setBool(_keyWasInactive, wasInactive);

    // Important:
    // null = keep existing refresh token
    // empty string = remove refresh token
    // non-empty = save refresh token
    if (refreshToken != null) {
      final cleanRefresh = refreshToken.trim();

      if (cleanRefresh.isEmpty) {
        await sp.remove(_keyRefreshToken);
        _log('saveToken() refresh removed because empty string was passed');
      } else {
        await sp.setString(_keyRefreshToken, cleanRefresh);
        _log('saveToken() refresh saved len=${cleanRefresh.length}');
      }
    } else {
      final existingRefresh = sp.getString(_keyRefreshToken);
      _log(
        'saveToken() refreshToken is null, keeping existing = ${existingRefresh != null && existingRefresh.isNotEmpty}',
      );
    }

    if (tenantId != null) {
      final cleanTenant = tenantId.trim();

      if (cleanTenant.isEmpty) {
        await sp.remove(_keyTenantId);
      } else {
        await sp.setString(_keyTenantId, cleanTenant);
      }
    }

    if (userJson != null) {
      await sp.setString(_keyUserJson, jsonEncode(userJson));
    }

    await debugDump();
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(_keyToken);

    _log('getToken() -> ${token == null ? "null" : "exists len=${token.length}"}');

    return token;
  }

  Future<String?> getRefreshToken() async {
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString(_keyRefreshToken);

    _log(
      'getRefreshToken() -> ${refresh == null ? "null" : "exists len=${refresh.length}"}',
    );

    return refresh;
  }

  Future<String?> getTenantId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyTenantId);
  }

  Future<bool> getWasInactive() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_keyWasInactive) ?? false;
  }

  Future<Map<String, dynamic>?> getUserJson() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_keyUserJson);

    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();

    _log('clear() called');

    await sp.remove(_keyToken);
    await sp.remove(_keyRefreshToken);
    await sp.remove(_keyTenantId);
    await sp.remove(_keyUserJson);
    await sp.remove(_keyWasInactive);

    await debugDump();
  }

  Future<void> clearToken() => clear();

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  Future<void> debugDump() async {
    final sp = await SharedPreferences.getInstance();

    final token = sp.getString(_keyToken);
    final refresh = sp.getString(_keyRefreshToken);
    final tenant = sp.getString(_keyTenantId);
    final userJson = sp.getString(_keyUserJson);
    final wasInactive = sp.getBool(_keyWasInactive);

    _log('--- DEBUG DUMP ---');
    _log('token = ${token == null ? "null" : "exists len=${token.length}"}');
    _log('refresh = ${refresh == null ? "null" : "exists len=${refresh.length}"}');
    _log('tenant = ${tenant ?? "null"}');
    _log('userJson = ${userJson == null ? "null" : "exists len=${userJson.length}"}');
    _log('wasInactive = ${wasInactive ?? false}');
    _log('------------------');
  }
}