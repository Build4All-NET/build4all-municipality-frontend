// lib/core/network/interceptors/auth_body_injector.dart

import 'package:baladiyati/core/network/globals.dart' as Env;
import 'package:dio/dio.dart';

class OwnerInjector extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final ownerId = Env.ownerProjectLinkId?.trim() ?? '';

    if (ownerId.isNotEmpty) {
      // Municipality backend expects this one.
      options.headers['Owner-Project-Link-Id'] = ownerId;

      // Keep this too for compatibility with other endpoints.
      options.headers['X-Owner-Project-Link-Id'] = ownerId;
    }

    final token = Env.readAuthToken().trim();
    final currentAuth = (options.headers['Authorization'] ?? '').toString();

    if (token.isNotEmpty && currentAuth.isEmpty) {
      options.headers['Authorization'] =
          token.toLowerCase().startsWith('bearer ') ? token : 'Bearer $token';
    }

    handler.next(options);
  }
}