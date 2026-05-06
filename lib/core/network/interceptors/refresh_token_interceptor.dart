import 'dart:convert';

import 'package:baladiyati/core/network/auth_refresh_coordinator.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/network/globals.dart' as g;
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:dio/dio.dart';

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor(this._dio);

  final Dio _dio;

  final AuthTokenStore _userStore = AuthTokenStore();
  final AdminTokenStore _adminStore = const AdminTokenStore();
  final AuthRefreshCoordinator _refresh = AuthRefreshCoordinator.instance;

  bool _isAuthCall(RequestOptions options) {
    final path = options.path.toLowerCase();

    return path.contains('/auth/refresh') ||
        path.contains('/auth/logout') ||
        path.contains('/auth/user/login') ||
        path.contains('/auth/user/login-phone') ||
        path.contains('/auth/admin/login') ||
        path.contains('/auth/admin/login/front') ||
        path.contains('/auth/manager/login') ||
        path.contains('/auth/superadmin/login') ||
        path.contains('/send-verification') ||
        path.contains('/verify-email-code') ||
        path.contains('/verify-phone-code');
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
      if (rawJwt.trim().isEmpty) {
        return null;
      }

      final parts = rawJwt.split('.');

      if (parts.length < 2) {
        return null;
      }

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);

      if (map is! Map) {
        return null;
      }

      return map['role']?.toString().toUpperCase().trim();
    } catch (_) {
      return null;
    }
  }

  bool _isAdminRole(String? role) {
    if (role == null) {
      return false;
    }

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

    // Refresh only on 401.
    // 403 usually means permission denied, not expired token.
    if (status != 401 || _isAuthCall(req)) {
      return handler.next(err);
    }

    // Avoid infinite retry loop.
    if (req.extra['__retried'] == true) {
      return handler.next(err);
    }

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

      // IMPORTANT:
      // Retry with the SAME Dio that failed.
      // Municipality failed request retries on municipalityDio.
      // Build4All failed request retries on build4allDio.
      final response = await _dio.fetch<dynamic>(req);

      return handler.resolve(response);
    } catch (e) {
      final shouldClear = _refresh.shouldClearAfterRefreshFailure(e);

      if (shouldClear) {
        if (isAdmin) {
          await _adminStore.clear();
        } else {
          await _userStore.clear();
        }

        g.setAuthToken('');
        DioClient.clearAuthToken();
      }

      return handler.next(err);
    }
  }
}