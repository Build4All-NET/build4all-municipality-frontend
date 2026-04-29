import 'dart:async';

import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/network/globals.dart' as g;
import 'package:baladiyati/core/utils/jwt_utils.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';

class AuthRefreshCoordinator {
  AuthRefreshCoordinator._();

  static final AuthRefreshCoordinator instance = AuthRefreshCoordinator._();

  final AuthTokenStore _userStore =  AuthTokenStore();
  final AdminTokenStore _adminStore = const AdminTokenStore();

  Completer<String>? _userRefreshing;
  Completer<String>? _adminRefreshing;

  Dio _plain() {
    return Dio(
      BaseOptions(
        baseUrl: g.appServerRoot,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  String _stripBearer(String? token) {
    final v = (token ?? '').trim();
    if (v.toLowerCase().startsWith('bearer ')) {
      return v.substring(7).trim();
    }
    return v;
  }

  bool shouldClearAfterRefreshFailure(Object e) {
    if (e is DioException) {
      final s = e.response?.statusCode ?? 0;
      if (s == 401) return true;
    }

    final msg = e.toString().toUpperCase();
    return msg.contains('NO_USER_REFRESH') ||
        msg.contains('NO_ADMIN_REFRESH') ||
        msg.contains('BAD_REFRESH') ||
        msg.contains('BAD_REFRESH_RESPONSE');
  }

  Future<String> refreshUser({String? tenantId}) async {
    if (_userRefreshing != null) return _userRefreshing!.future;

    final completer = Completer<String>();
    _userRefreshing = completer;

    try {
      final refresh = (await _userStore.getRefreshToken())?.trim() ?? '';
      if (refresh.isEmpty) throw Exception('NO_USER_REFRESH');

      final res = await _plain().post(
        '/api/auth/refresh',
        data: {'refreshToken': refresh},
      );

      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final newAccess = (data['token'] ?? '').toString().trim();
      final newRefresh = (data['refreshToken'] ?? '').toString().trim();

      if (newAccess.isEmpty || newRefresh.isEmpty) {
        throw Exception('BAD_REFRESH_RESPONSE');
      }
await _userStore.saveToken(
  token: newAccess,
  refreshToken: newRefresh,
  tenantId: tenantId,
  wasInactive: false,
);
      // await _userStore.saveToken(
      //   token: newAccess,
      //   wasInactive: false,
      //   refreshToken: newRefresh,
      //   tenantId: tenantId,
      // );

      g.setAuthToken(newAccess);

      completer.complete(newAccess);
      return newAccess;
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _userRefreshing = null;
    }
  }

  Future<String> refreshAdmin({String? tenantId}) async {
    if (_adminRefreshing != null) return _adminRefreshing!.future;

    final completer = Completer<String>();
    _adminRefreshing = completer;

    try {
      final refresh = (await _adminStore.getRefreshToken())?.trim() ?? '';
      if (refresh.isEmpty) throw Exception('NO_ADMIN_REFRESH');

      final res = await _plain().post(
        '/api/auth/refresh',
        data: {'refreshToken': refresh},
      );

      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final newAccess = (data['token'] ?? '').toString().trim();
      final newRefresh = (data['refreshToken'] ?? '').toString().trim();

      if (newAccess.isEmpty || newRefresh.isEmpty) {
        throw Exception('BAD_REFRESH_RESPONSE');
      }

      final role = (await _adminStore.getRole()) ?? '';

      await _adminStore.save(
        token: newAccess,
        role: role,
        refreshToken: newRefresh,
        tenantId: tenantId,
      );

      g.setAuthToken(newAccess);

      completer.complete(newAccess);
      return newAccess;
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _adminRefreshing = null;
    }
  }

  Future<String?> refreshUserIfNeeded({
    required String? tokenStored,
    required bool userWasInactive,
    String? tenantId,
  }) async {
    if (userWasInactive) return null;

    final refresh = (await _userStore.getRefreshToken())?.trim() ?? '';
    if (refresh.isEmpty) return null;

    final raw = _stripBearer(tokenStored);
    if (raw.isNotEmpty && !JwtUtils.isExpired(raw)) {
      return raw;
    }

    try {
      return await refreshUser(tenantId: tenantId);
    } catch (_) {
      await _userStore.clearToken();
      return null;
    }
  }

  Future<String?> refreshAdminIfNeeded({
    required String? tokenStored,
    String? tenantId,
  }) async {
    final refresh = (await _adminStore.getRefreshToken())?.trim() ?? '';
    if (refresh.isEmpty) return null;

    final raw = _stripBearer(tokenStored);
    if (raw.isNotEmpty && !JwtUtils.isExpired(raw)) {
      return raw;
    }

    try {
      return await refreshAdmin(tenantId: tenantId);
    } catch (_) {
      await _adminStore.clear();
      return null;
    }
  }
}