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
    final municipalityBaseUrl = _withApiSuffix(Env.overrideBaseUrl);

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

    final cleanToken = globals.readAuthToken();

    if (cleanToken.trim().isEmpty) {
      build4allDio.options.headers.remove('Authorization');
      municipalityDio.options.headers.remove('Authorization');
      return;
    }

    build4allDio.options.headers['Authorization'] = cleanToken;
    municipalityDio.options.headers['Authorization'] = cleanToken;
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

  static String _withApiSuffix(String rawUrl) {
    final clean = rawUrl.trim().replaceAll(RegExp(r'/+$'), '');

    if (clean.endsWith('/api')) {
      return clean;
    }
print('OWNER_PROJECT_LINK_ID = ${Env.ownerProjectLinkId}');
print('PROJECT_ID = ${Env.projectId}');
    return '$clean/api';

    
  }
}