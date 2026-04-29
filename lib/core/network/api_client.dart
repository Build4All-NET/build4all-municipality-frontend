// lib/core/network/api_client.dart

import 'dart:convert';

import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/network_exception.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // Municipality API base URL comes from dart-define/env.
  static String get baseUrl => Env.overrideBaseUrl.replaceAll(RegExp(r'/+$'), '');

  final AuthTokenStore _tokenStore;

  ApiClient({
    AuthTokenStore? tokenStore,
  }) : _tokenStore = tokenStore ?? AuthTokenStore();

  Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? extraHeaders,
  }) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _headers(
            requiresAuth: requiresAuth,
            extraHeaders: extraHeaders,
          ),
        )
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    Map<String, String>? extraHeaders,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _headers(
            requiresAuth: requiresAuth,
            extraHeaders: extraHeaders,
          ),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  Future<dynamic> postToUrl(
    String fullUrl, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    Map<String, String>? extraHeaders,
  }) async {
    final response = await http
        .post(
          Uri.parse(fullUrl),
          headers: await _headers(
            requiresAuth: requiresAuth,
            extraHeaders: extraHeaders,
          ),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    Map<String, String>? extraHeaders,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _headers(
            requiresAuth: requiresAuth,
            extraHeaders: extraHeaders,
          ),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  Future<Map<String, String>> _headers({
    bool requiresAuth = false,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _tokenStore.getToken();

      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${_normalizeToken(token)}';
      }
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};

      final trimmed = response.body.trim();

      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        return jsonDecode(trimmed);
      }

      return {'message': trimmed};
    }

    try {
      final trimmed = response.body.trim();

      if (trimmed.startsWith('{')) {
        final error = jsonDecode(trimmed);
        final code = error['code'] ?? error['error'] ?? 'UNKNOWN';
        final message = error['message'] ?? 'Something went wrong';

        throw AppException(message, code: code);
      }

      throw AppException(
        trimmed.isNotEmpty ? trimmed : 'Error ${response.statusCode}',
      );
    } catch (e) {
      if (e is AppException) rethrow;

      throw ServerException(
        'Server error. Please try later',
        statusCode: response.statusCode,
      );
    }
  }

  String _normalizeToken(String token) {
    final value = token.trim();

    if (value.toLowerCase().startsWith('bearer ')) {
      return value.substring(7).trim();
    }

    return value;
  }

  Future<void> saveToken(String token) => _tokenStore.saveToken(token: token);

  Future<String?> getToken() => _tokenStore.getToken();

  Future<void> clearToken() => _tokenStore.clear();
}