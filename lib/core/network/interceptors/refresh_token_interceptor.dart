import 'dart:convert';

import 'package:baladiyati/core/network/auth_refresh_coordinator.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/network/globals.dart' as g;
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:dio/dio.dart';

class RefreshTokenInterceptor extends Interceptor {
  final AuthTokenStore _userStore = AuthTokenStore();
  final AdminTokenStore _adminStore = const AdminTokenStore();
  final AuthRefreshCoordinator _refresh = AuthRefreshCoordinator.instance;

  bool _isAuthCall(RequestOptions options) {
    final path = options.path;

    return path.contains('/api/auth/refresh') ||
        path.contains('/api/auth/logout') ||
        path.contains('/api/auth/user/login') ||
        path.contains('/api/auth/user/login-phone') ||
        path.contains('/api/auth/admin/login') ||
        path.contains('/api/auth/admin/login/front') ||
        path.contains('/api/auth/manager/login') ||
        path.contains('/api/auth/superadmin/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout') ||
        path.contains('/auth/user/login') ||
        path.contains('/auth/admin/login');
  }

  String _rawTokenFromAuthHeader(String auth) {
    final value = auth.trim();

    if (value.toLowerCase().startsWith('bearer ')) {
      return value.substring(7).trim();
    }

    return value;
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

      return map['role']?.toString().toUpperCase().trim();
    } catch (_) {
      return null;
    }
  }

  bool _isAdminRole(String? role) {
    if (role == null) return false;

    return role == 'OWNER' ||
        role == 'SUPER_ADMIN' ||
        role == 'MANAGER' ||
        role == 'ADMIN' ||
        role == 'STAFF';
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode ?? 0;
    final req = err.requestOptions;

    // Refresh only for 401.
    if ((status != 401 && status != 403) || _isAuthCall(req)) {
  return handler.next(err);
}

    // Avoid infinite retry loop.
    if (req.extra['__retried'] == true) {
      return handler.next(err);
    }

    // If request had no auth token, refresh makes no sense.
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
      final tenantId = g.ownerProjectLinkId;


      final newToken = isAdmin
          ? await _refresh.refreshAdmin(tenantId: tenantId)
          : await _refresh.refreshUser(tenantId: tenantId);

          DioClient.setAuthToken(newToken);

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