import 'package:shared_preferences/shared_preferences.dart';

class JwtStore {
  static const _k = 'sa_jwt';
  static Future<void> save(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, token.trim());
  }

  static Future<String> read() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_k) ?? '';
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_k);
  }
}
