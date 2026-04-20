import 'package:dio/dio.dart';
import 'api_config.dart';

class DioClient {
  static late Dio municipalityDio;
  static late Dio build4allDio;

  static Future<void> init() async {
    final config = await ApiConfig.load();

    // ✅ MUNICIPALITY API
    municipalityDio = Dio(
      BaseOptions(
        baseUrl: "${config.municipalityBaseUrl}/api", // ✅ add /api
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Accept": "application/json",
        },
      ),
    );

    // ✅ BUILD4ALL AUTH API
    build4allDio = Dio(
      BaseOptions(
        baseUrl: "${config.build4allBaseUrl}/api", // ✅ add /api
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Accept": "application/json",
        },
      ),
    );

    // 🔍 Logging interceptor (CRITICAL for debugging)
    build4allDio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    municipalityDio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  static Dio get muni => municipalityDio;
  static Dio get build => build4allDio;
}