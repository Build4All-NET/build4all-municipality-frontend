// lib/core/network/interceptors/auth_body_injector.dart

import 'package:baladiyati/core/network/globals.dart' as Env;
import 'package:dio/dio.dart';

/// Interceptor that injects ownerProjectLinkId + auth token
/// into every request.
class OwnerInjector extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ─────────────────────────────────────────
    // 1) Inject ownerProjectLinkId safely
    // ─────────────────────────────────────────
    final ownerId = Env.ownerProjectLinkId?.trim() ?? '';

    if (ownerId.isNotEmpty) {
      options.headers['X-Owner-Project-Link-Id'] = ownerId;
    }

    // ─────────────────────────────────────────
    // 2) Inject Authorization token safely
    // ─────────────────────────────────────────
    final token = Env.readAuthToken()?.trim() ?? '';
    final currentAuth = (options.headers['Authorization'] ?? '').toString();

    if (token.isNotEmpty && currentAuth.isEmpty) {
      options.headers['Authorization'] =
          token.startsWith('Bearer ') ? token : 'Bearer $token';
    }

    // ─────────────────────────────────────────
    // optional debug
    // ─────────────────────────────────────────
    // print('🟦 OwnerInjector headers → ${options.headers}');

    handler.next(options);
  }
}