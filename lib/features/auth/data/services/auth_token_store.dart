import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStore {
  static const _keyToken = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyTenantId = 'auth_tenant_id';
  static const _keyUserJson = 'auth_user_json';
  static const _keyWasInactive = 'was_inactive';

  Future<void> saveToken({
    required String token,
    String? refreshToken,
    String? tenantId,
    bool wasInactive = false,
    Map<String, dynamic>? userJson,
  }) async {
    final sp = await SharedPreferences.getInstance();

    await sp.setString(_keyToken, token.trim());
    await sp.setBool(_keyWasInactive, wasInactive);

    if (refreshToken != null) {
      final clean = refreshToken.trim();
      if (clean.isEmpty) {
        await sp.remove(_keyRefreshToken);
      } else {
        await sp.setString(_keyRefreshToken, clean);
      }
    }

    if (tenantId != null) {
      final clean = tenantId.trim();
      if (clean.isEmpty) {
        await sp.remove(_keyTenantId);
      } else {
        await sp.setString(_keyTenantId, clean);
      }
    }

    if (userJson != null) {
      await sp.setString(_keyUserJson, jsonEncode(userJson));
    }
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyToken);
  }

  Future<String?> getRefreshToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyRefreshToken);
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

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyToken);
    await sp.remove(_keyRefreshToken);
    await sp.remove(_keyTenantId);
    await sp.remove(_keyUserJson);
    await sp.remove(_keyWasInactive);
  }

  // Backward compatibility with old code.
  Future<void> clearToken() => clear();

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }
}