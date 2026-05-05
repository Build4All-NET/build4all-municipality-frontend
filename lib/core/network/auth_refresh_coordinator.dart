import 'dart:async';

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:baladiyati/core/network/globals.dart' as g;
import 'package:baladiyati/core/utils/jwt_utils.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:dio/dio.dart';

class AuthRefreshCoordinator {
  AuthRefreshCoordinator._();

  static final AuthRefreshCoordinator instance = AuthRefreshCoordinator._();

  final AuthTokenStore _userStore = AuthTokenStore();
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
    final value = (token ?? '').trim();

    if (value.toLowerCase().startsWith('bearer ')) {
      return value.substring(7).trim();
    }

    return value;
  }

  Map<String, dynamic> _readPayload(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }

  AuthException _mapRefreshDioError(
    DioException e, {
    required int? status,
    required Map<String, dynamic> payload,
  }) {
    final code = (payload['code'] ?? '').toString().trim();
    final message = (payload['message'] ?? payload['error'] ?? '')
        .toString()
        .trim();

    if (status == 401 || status == 403) {
      return AuthException(
        message.isEmpty ? 'Session expired. Please login again.' : message,
        code: code.isEmpty ? 'BAD_REFRESH' : code,
        original: e,
      );
    }

    return AuthException(
      message.isEmpty ? 'Refresh failed.' : message,
      code: code.isEmpty ? 'BAD_REFRESH' : code,
      original: e,
    );
  }

  bool shouldClearAfterRefreshFailure(Object e) {
    if (e is AuthException) {
      final code = (e.code ?? '').trim().toUpperCase();

      return code == 'NO_USER_REFRESH' ||
          code == 'NO_ADMIN_REFRESH' ||
          code == 'BAD_REFRESH' ||
          code == 'BAD_REFRESH_RESPONSE' ||
          code == 'SESSION_EXPIRED';
    }

    if (e is DioException) {
      final status = e.response?.statusCode ?? 0;
      return status == 401 || status == 403;
    }

    if (e is AppException) {
      final code = (e.code ?? '').trim().toUpperCase();

      return code == 'NO_USER_REFRESH' ||
          code == 'NO_ADMIN_REFRESH' ||
          code == 'BAD_REFRESH' ||
          code == 'BAD_REFRESH_RESPONSE' ||
          code == 'SESSION_EXPIRED';
    }

    final text = e.toString().toUpperCase();

    return text.contains('NO_USER_REFRESH') ||
        text.contains('NO_ADMIN_REFRESH') ||
        text.contains('BAD_REFRESH') ||
        text.contains('BAD_REFRESH_RESPONSE') ||
        text.contains('SESSION_EXPIRED');
  }

  Future<String> refreshUser({String? tenantId}) async {
    if (_userRefreshing != null) {
      return _userRefreshing!.future;
    }

    final completer = Completer<String>();
    _userRefreshing = completer;

    try {
      final refresh = (await _userStore.getRefreshToken())?.trim() ?? '';

      if (refresh.isEmpty) {
        throw AuthException(
          'No refresh token available.',
          code: 'NO_USER_REFRESH',
        );
      }

     final response = await _plain().post(
  '/api/auth/admin/refresh',
  data: {
    'refreshToken': refresh,
    'ownerProjectLinkId': tenantId,
  },
);
      final data = _readPayload(response.data);

      final newAccess = (data['token'] ??
              data['accessToken'] ??
              data['jwt'] ??
              data['access_token'] ??
              '')
          .toString()
          .trim();

      final newRefresh = (data['refreshToken'] ??
              data['refresh_token'] ??
              '')
          .toString()
          .trim();

      if (newAccess.isEmpty || newRefresh.isEmpty) {
        throw AuthException(
          'Invalid refresh response.',
          code: 'BAD_REFRESH_RESPONSE',
        );
      }

      await _userStore.saveToken(
        token: _stripBearer(newAccess),
        refreshToken: newRefresh,
        tenantId: tenantId,
        wasInactive: false,
      );

      g.setAuthToken(_stripBearer(newAccess));

      completer.complete(_stripBearer(newAccess));
      return _stripBearer(newAccess);
    } on DioException catch (e, st) {
      final mapped = _mapRefreshDioError(
        e,
        status: e.response?.statusCode,
        payload: _readPayload(e.response?.data),
      );

      completer.completeError(mapped, st);
      throw mapped;
    } catch (e, st) {
      if (e is AppException) {
        completer.completeError(e, st);
        rethrow;
      }

      final wrapped = AppException(
        'Refresh failed.',
        original: e,
      );

      completer.completeError(wrapped, st);
      throw wrapped;
    } finally {
      _userRefreshing = null;
    }
  }

  Future<String> refreshAdmin({String? tenantId}) async {
    if (_adminRefreshing != null) {
      return _adminRefreshing!.future;
    }

    final completer = Completer<String>();
    _adminRefreshing = completer;

    try {
      final refresh = (await _adminStore.getRefreshToken())?.trim() ?? '';

      if (refresh.isEmpty) {
        throw AuthException(
          'No refresh token available.',
          code: 'NO_ADMIN_REFRESH',
        );
      }

      final response = await _plain().post(
        '/api/auth/refresh',
        data: {
          'refreshToken': refresh,
        },
      );

      final data = _readPayload(response.data);

      final newAccess = (data['token'] ??
              data['accessToken'] ??
              data['jwt'] ??
              data['access_token'] ??
              '')
          .toString()
          .trim();

      final newRefresh = (data['refreshToken'] ??
              data['refresh_token'] ??
              '')
          .toString()
          .trim();

      if (newAccess.isEmpty || newRefresh.isEmpty) {
        throw AuthException(
          'Invalid refresh response.',
          code: 'BAD_REFRESH_RESPONSE',
        );
      }

      final role = (await _adminStore.getRole()) ?? '';

      await _adminStore.save(
        token: _stripBearer(newAccess),
        role: role,
        refreshToken: newRefresh,
        tenantId: tenantId,
      );

      g.setAuthToken(_stripBearer(newAccess));

      completer.complete(_stripBearer(newAccess));
      return _stripBearer(newAccess);
    } on DioException catch (e, st) {
      final mapped = _mapRefreshDioError(
        e,
        status: e.response?.statusCode,
        payload: _readPayload(e.response?.data),
      );

      completer.completeError(mapped, st);
      throw mapped;
    } catch (e, st) {
      if (e is AppException) {
        completer.completeError(e, st);
        rethrow;
      }

      final wrapped = AppException(
        'Refresh failed.',
        original: e,
      );

      completer.completeError(wrapped, st);
      throw wrapped;
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
    } catch (e) {
      if (shouldClearAfterRefreshFailure(e)) {
        await _userStore.clearToken();
      }

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
    } catch (e) {
      if (shouldClearAfterRefreshFailure(e)) {
        await _adminStore.clear();
      }

      return null;
    }
  }
}