import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/network/globals.dart' as globals;
import 'package:baladiyati/core/network/interceptors/auth_body_injector.dart';
import 'package:baladiyati/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:dio/dio.dart';

class DioClient {
  static late Dio municipalityDio;
  static late Dio build4allDio;

  static Future<void> init() async {
    final build4allBaseUrl = _withApiSuffix(Env.apiBaseUrl);
    final municipalityBaseUrl = _cleanBaseUrl(Env.overrideBaseUrl);

    print('BUILD4ALL_BASE_URL = $build4allBaseUrl');
    print('MUNICIPALITY_BASE_URL = $municipalityBaseUrl');
    print('OWNER_PROJECT_LINK_ID = ${Env.ownerProjectLinkId}');
    print('PROJECT_ID = ${Env.projectId}');

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
  }

  static Dio get build => build4allDio;

  static Dio get muni => municipalityDio;

 static void setAuthToken(String? token) {
  globals.setAuthToken(token);

  final raw = (token ?? '').trim();

  if (raw.isEmpty) {
    build4allDio.options.headers.remove('Authorization');
    municipalityDio.options.headers.remove('Authorization');
    return;
  }

  final bearer = raw.toLowerCase().startsWith('bearer ')
      ? raw
      : 'Bearer $raw';

  build4allDio.options.headers['Authorization'] = bearer;
  municipalityDio.options.headers['Authorization'] = bearer;
}
  static void clearAuthToken() {
    setAuthToken(null);
  }

  static void _attachCommonInterceptors(Dio dio) {
    dio.interceptors.clear();

    dio.interceptors.add(RefreshTokenInterceptor());
    dio.interceptors.add(OwnerInjector());

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
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