import 'dart:convert';

import 'package:baladiyati/core/network/auth_refresh_coordinator.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/network/globals.dart' as g;


class RefreshTokenInterceptor extends Interceptor {
  final AuthTokenStore _userStore =  AuthTokenStore();
  final AdminTokenStore _adminStore = const AdminTokenStore();
  final AuthRefreshCoordinator _refresh = AuthRefreshCoordinator.instance;

  bool _isAuthCall(RequestOptions o) {
    final p = o.path;
    return p.contains('/api/auth/refresh') ||
        p.contains('/api/auth/logout') ||
        p.contains('/api/auth/user/login') ||
        p.contains('/api/auth/user/login-phone') ||
        p.contains('/api/auth/admin/login') ||
        p.contains('/api/auth/admin/login/front') ||
        p.contains('/api/auth/manager/login') ||
        p.contains('/api/auth/superadmin/login');
  }

  String _rawTokenFromAuthHeader(String auth) {
    final t = auth.trim();
    if (t.toLowerCase().startsWith('bearer ')) return t.substring(7).trim();
    return t;
  }

  String? _roleFromJwt(String rawJwt) {
    try {
      if (rawJwt.trim().isEmpty) return null;

      final parts = rawJwt.split('.');
      if (parts.length < 2) return null;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);

      if (map is! Map) return null;

      final role = map['role']?.toString();
      return role?.toUpperCase().trim();
    } catch (_) {
      return null;
    }
  }

  bool _isAdminRole(String? role) {
    if (role == null) return false;
    return role == 'OWNER' ||
        role == 'STAFF' ||
        role == 'CITIZEN' ||
        role == 'ADMIN';
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode ?? 0;
    final req = err.requestOptions;

    // ✅ refresh ONLY on 401
    if (status != 401 || _isAuthCall(req)) {
      return handler.next(err);
    }

    // ✅ avoid infinite loop
    if (req.extra['__retried'] == true) {
      return handler.next(err);
    }

    // ✅ if request had no auth token, don't try refresh
    final authHeader = (req.headers['Authorization'] ?? '').toString().trim();
    final globalAuth = g.readAuthToken().trim();

    final hadAuth = authHeader.isNotEmpty || globalAuth.isNotEmpty;
    if (!hadAuth) {
      return handler.next(err);
    }

    final raw = _rawTokenFromAuthHeader(
      authHeader.isNotEmpty ? authHeader : globalAuth,
    );
    final role = _roleFromJwt(raw);
    final isAdmin = _isAdminRole(role);

    try {
      late final String newToken;

      if (isAdmin) {
        newToken = await _refresh.refreshAdmin();
      } else {
        newToken = await _refresh.refreshUser();
      }

      req.headers['Authorization'] =
      newToken.toLowerCase().startsWith('bearer ')
          ? newToken
          : 'Bearer $newToken';

      req.extra['__retried'] = true;
      final response = await g.dio().fetch(req);
      return handler.resolve(response);
    } catch (e) {
      final shouldClear = _refresh.shouldClearAfterRefreshFailure(e);

      if (shouldClear) {
        if (isAdmin) {
          await _adminStore.clear();
        } else {
          await _userStore.clearToken();
        }
        g.setAuthToken('');
      }

      return handler.next(err);
    }
  }
}