import 'package:shared_preferences/shared_preferences.dart';

class SessionRoleStore {
  static const _key = 'session_role';

  Future<void> saveRole(String role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, role.trim().toUpperCase());
  }

  Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_key)?.trim().toUpperCase();
  }

  Future<void> clearRole() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }

  Future<bool> isCitizen() async {
    final role = await getRole();
    return role == 'CITIZEN' || role == 'USER';
  }

  Future<bool> isStaff() async {
    final role = await getRole();
    return role == 'STAFF';
  }

  Future<bool> isOwner() async {
    final role = await getRole();
    return role == 'OWNER';
  }
}