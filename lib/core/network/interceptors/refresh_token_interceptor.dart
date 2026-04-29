// lib/core/network/interceptors/refresh_token_interceptor.dart

import 'dart:convert';

import 'package:baladiyati/core/network/auth_refresh_coordinator.dart';
import 'package:baladiyati/core/network/globals.dart' as g;
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:dio/dio.dart';

class RefreshTokenInterceptor extends Interceptor {
  final AuthTokenStore _userStore = AuthTokenStore();
  final AdminTokenStore _adminStore = const AdminTokenStore();
  final AuthRefreshCoordinator _refresh = AuthRefreshCoordinator.instance;
  final SessionRoleStore _roleStore = SessionRoleStore();

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

  String _normalizeToken(String token) {
    final t = token.trim();
    if (t.toLowerCase().startsWith('bearer ')) {
      return t.substring(7).trim();
    }
    return t;
  }

  bool _isAdminRole(String? role) {
    if (role == null) return false;

    return role == 'OWNER' ||
        role == 'SUPER_ADMIN' ||
        role == 'MANAGER' ||
        role == 'ADMIN' ||
        role == 'STAFF';
  }

  // 🔥 ADD AUTH HEADER BEFORE REQUEST
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final role = await _roleStore.getRole();

      String? token;

      if (_isAdminRole(role)) {
        token = await _adminStore.getToken();
      } else {
        token = await _userStore.getToken();
      }

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${_normalizeToken(token)}';
      }
    } catch (_) {}

    handler.next(options);
  }

  // 🔁 HANDLE 401 → REFRESH
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode ?? 0;
    final req = err.requestOptions;

    // ❌ ignore non-401 or auth endpoints
    if (status != 401 || _isAuthCall(req)) {
      return handler.next(err);
    }

    // ❌ avoid infinite loop
    if (req.extra['__retried'] == true) {
      return handler.next(err);
    }

    try {
      final role = await _roleStore.getRole();
      final isAdmin = _isAdminRole(role);

      late final String newToken;

      if (isAdmin) {
        newToken = await _refresh.refreshAdmin();
      } else {
        newToken = await _refresh.refreshUser();
      }

      req.headers['Authorization'] =
          'Bearer ${_normalizeToken(newToken)}';

      req.extra['__retried'] = true;

      final response = await g.dio().fetch(req);

      return handler.resolve(response);
    } catch (e) {
      final shouldClear = _refresh.shouldClearAfterRefreshFailure(e);

      if (shouldClear) {
        final role = await _roleStore.getRole();

        if (_isAdminRole(role)) {
          await _adminStore.clear();
        } else {
          await _userStore.clear();
        }

        g.setAuthToken('');
      }

      return handler.next(err);
    }
  }
}