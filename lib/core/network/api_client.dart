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
  static const String baseUrl = 'http://10.0.2.2:8091';
  static const String _tokenKey = 'auth_token';

  // ─────────────────────────────────────────
  // GET request
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  // ─────────────────────────────────────────
  // POST request
  // ─────────────────────────────────────────
  Future<Map<String, dynamic>> post(
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
  // Handle response
  // ─────────────────────────────────────────
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }

    try {
      final error = jsonDecode(response.body);
      final code = error['code'] ?? error['error'] ?? 'UNKNOWN';
      final message = error['message'] ?? 'Something went wrong';
      throw AppException(message, code: code);
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
