// lib/features/auth/data/services/auth_token_store.dart
// ─────────────────────────────────────────
// Saves and loads the JWT token locally
// Like the doctor's auth_token_store.dart
// ─────────────────────────────────────────

import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStore {
  static const _key = 'auth_token';

  Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, token);
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_key);
  }

  Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

 Future<String?> getRefreshToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_key);
  }
}