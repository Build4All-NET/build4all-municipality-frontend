// lib/core/network/api_client.dart
// ─────────────────────────────────────────
// Central HTTP client for all API calls
// Handles headers, errors, and token
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/network_exception.dart';
import '../exceptions/app_exception.dart';

class ApiClient {
  // Web (Chrome):      http://localhost:8091
  // Android Emulator:  http://10.0.2.2:8091
  // Real Phone (WiFi): http://192.168.0.101:8091
  static const String baseUrl = 'http://localhost:8091';
  static const String _tokenKey = 'auth_token';

  // ─────────────────────────────────────────
  // GET request
  // ─────────────────────────────────────────
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // POST request
  // ─────────────────────────────────────────
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    ).timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // Build headers
  // ─────────────────────────────────────────
  Future<Map<String, String>> _headers({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ─────────────────────────────────────────
  // Handle response — supports BOTH:
  //   - Plain String: "Verification email sent"
  //   - JSON Object:  { "token": "...", "message": "..." }
  // ─────────────────────────────────────────
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Empty body
      if (response.body.isEmpty) return {};

      final trimmed = response.body.trim();

      // If it starts with { or [ → it's JSON
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        return jsonDecode(trimmed);
      }

      //  If it's a plain String (like "Verification email sent successfully")
      return {'message': trimmed};
    }

    // ─── Error handling ───────────────────
    try {
      final trimmed = response.body.trim();

      // Try to parse as JSON error
      if (trimmed.startsWith('{')) {
        final error = jsonDecode(trimmed);
        final code = error['code'] ?? error['error'] ?? 'UNKNOWN';
        final message = error['message'] ?? 'Something went wrong';
        throw AppException(message, code: code);
      }

      // Plain string error
      throw AppException(trimmed.isNotEmpty ? trimmed : 'Error ${response.statusCode}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException.serverError();
    }
  }

  // ─────────────────────────────────────────
  // Token helpers
  // ─────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_tokenKey);
  }
}