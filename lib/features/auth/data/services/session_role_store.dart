// lib/features/auth/data/services/session_role_store.dart
// ─────────────────────────────────────────
// Saves user role (CITIZEN or EMPLOYEE)
// Like the doctor's session_role_store.dart
// ─────────────────────────────────────────

import 'package:shared_preferences/shared_preferences.dart';

class SessionRoleStore {
  static const _key = 'session_role';

  Future<void> saveRole(String role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, role);
  }

  Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_key);
  }

  Future<void> clearRole() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }

  Future<bool> isCitizen() async {
    final role = await getRole();
    return role?.toUpperCase() == 'CITIZEN';
  }

  Future<bool> isEmployee() async {
    final role = await getRole();
    return role?.toUpperCase() == 'EMPLOYEE';
  }
}
