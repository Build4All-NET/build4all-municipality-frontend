import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/network/globals.dart' as globals;
import 'package:baladiyati/core/network/interceptors/app_error_interceptor.dart';
import 'package:baladiyati/core/network/interceptors/auth_body_injector.dart';
import 'package:baladiyati/core/network/interceptors/network_error_interceptor.dart';
import 'package:baladiyati/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';

class DioClient {
  static late Dio municipalityDio;
  static late Dio build4allDio;

  static Future<void> init() async {
    final build4allBaseUrl = _withApiSuffix(Env.apiBaseUrl);
    final municipalityBaseUrl = _cleanBaseUrl(Env.overrideBaseUrl);

    debugPrint('BUILD4ALL_BASE_URL = $build4allBaseUrl');
    debugPrint('MUNICIPALITY_BASE_URL = $municipalityBaseUrl');
    debugPrint('OWNER_PROJECT_LINK_ID = ${Env.ownerProjectLinkId}');
    debugPrint('PROJECT_ID = ${Env.projectId}');

    build4allDio = Dio(
      BaseOptions(
        baseUrl: build4allBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    municipalityDio = Dio(
      BaseOptions(
        baseUrl: municipalityBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _attachCommonInterceptors(build4allDio);
    _attachCommonInterceptors(municipalityDio);

    // Legacy compatibility: old code using globals.dio() will use Build4All by default.
    globals.makeDefaultDio(build4allBaseUrl);

    // Restore admin token after app restart if it exists.
  await _restoreSavedTokenIfAvailable();
  }

  static Dio get build => build4allDio;

  static Dio get muni => municipalityDio;

  static void setAuthToken(String? token) {
    globals.setAuthToken(token);

    final raw = (token ?? '').trim();

    if (raw.isEmpty) {
      if (_isInitialized()) {
        build4allDio.options.headers.remove('Authorization');
        municipalityDio.options.headers.remove('Authorization');
      }

      return;
    }

    final bearer = _asBearer(raw);

    build4allDio.options.headers['Authorization'] = bearer;
    municipalityDio.options.headers['Authorization'] = bearer;

    debugPrint('DioClient.setAuthToken => token attached to build + muni');
  }

  static void clearAuthToken() {
    setAuthToken(null);
  }

 static Future<void> _restoreSavedTokenIfAvailable() async {
  try {
    final adminStore = AdminTokenStore();
    final userStore = AuthTokenStore();

    final adminToken = await adminStore.getToken();

    if (adminToken != null && adminToken.trim().isNotEmpty) {
      setAuthToken(adminToken);
      debugPrint('DioClient.init => restored admin token');
      return;
    }

    final userToken = await userStore.getToken();

    if (userToken != null && userToken.trim().isNotEmpty) {
      setAuthToken(userToken);
      await JwtStore.save(userToken);

      debugPrint('DioClient.init => restored citizen token');
      return;
    }

    debugPrint('DioClient.init => no saved token found');
  } catch (e) {
    debugPrint('DioClient.init => failed to restore saved token: $e');
  }
}

 static void _attachCommonInterceptors(Dio dio) {
  dio.interceptors.clear();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final hasRequestAuth =
            options.headers['Authorization']?.toString().trim().isNotEmpty ??
                false;

        final globalAuth =
            dio.options.headers['Authorization']?.toString().trim();

        if (!hasRequestAuth && globalAuth != null && globalAuth.isNotEmpty) {
          options.headers['Authorization'] = globalAuth;
        }

        debugPrint('DIO REQUEST => ${options.method} ${options.uri}');
        debugPrint(
          'DIO AUTH HEADER => ${options.headers['Authorization'] != null ? 'YES' : 'NO'}',
        );

        return handler.next(options);
      },
    ),
  );

  dio.interceptors.add(RefreshTokenInterceptor(dio));
  dio.interceptors.add(OwnerInjector());


  dio.interceptors.add(NetworkErrorInterceptor());


  dio.interceptors.add(AppErrorInterceptor());

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ),
  );
}

  static String _asBearer(String token) {
    final clean = token.trim();

    if (clean.toLowerCase().startsWith('bearer ')) {
      return clean;
    }

    return 'Bearer $clean';
  }

  static bool _isInitialized() {
    try {
      build4allDio;
      municipalityDio;
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _cleanBaseUrl(String rawUrl) {
    return rawUrl.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static String _withApiSuffix(String rawUrl) {
    final clean = _cleanBaseUrl(rawUrl);

    if (clean.endsWith('/api')) {
      return clean;
    }

    return '$clean/api';
  }
}