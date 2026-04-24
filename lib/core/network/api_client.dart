// lib/core/network/api_client.dart
// ─────────────────────────────────────────
// Central HTTP client for all API calls
// Handles headers, errors, and token
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/network_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Web (Chrome):      http://localhost:8091
  // Android Emulator:  http://10.0.2.2:8091
  // Real Phone (WiFi): http://192.168.0.101:8091
  static const String baseUrl = 'https://static-sneeze-unfrozen.ngrok-free.dev';
  
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
  // POST request — uses baladiyati baseUrl
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
  // ✅ POST to full URL — for external APIs (build4all)
  // ─────────────────────────────────────────
  Future<dynamic> postToUrl(
    String fullUrl, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final response = await http.post(
      Uri.parse(fullUrl),
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

      throw AppException(trimmed.isNotEmpty ? trimmed : 'Error ${response.statusCode}');
    } catch (e) {
      if (e is AppException) rethrow;
throw ServerException(
  'Server error. Please try later',
  statusCode: response.statusCode,
);    }
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
