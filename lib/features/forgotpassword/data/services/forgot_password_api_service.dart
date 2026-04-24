import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:baladiyati/core/exceptions/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/forgot_password_models.dart';

class ForgotPasswordApiService {
  final http.Client _client;

  ForgotPasswordApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  String get _base => Env.apiBaseUrl;

  Uri _uri(
    String path, {
    Map<String, String>? query,
  }) {
    final u = Uri.parse('$_base$path');
    return query == null
        ? u
        : u.replace(queryParameters: query);
  }

  // ================= SEND RESET CODE =================

  Future<ForgotMessageResponse> sendResetCode({
    required String email,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri(
      '/api/users/reset-password',
      query: {
        'ownerProjectLinkId':
            ownerProjectLinkId.toString(),
      },
    );

    debugPrint('🔑 SEND RESET CODE → $uri');

    final resp = await _safePost(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    final decoded = _safeJson(resp.body);

    if (resp.statusCode >= 400) {
      _throwFromHttp(
        resp,
        decoded,
        fallback:
            'Failed to send reset code',
      );
    }

    return ForgotMessageResponse.fromJson(
      decoded,
    );
  }

  // ================= VERIFY RESET CODE =================

  Future<ForgotMessageResponse>
      verifyResetCode({
    required String email,
    required String code,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri(
      '/api/users/verify-reset-code',
      query: {
        'ownerProjectLinkId':
            ownerProjectLinkId.toString(),
      },
    );

    debugPrint(
      '✅ VERIFY RESET CODE → $uri',
    );

    final resp = await _safePost(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    final decoded = _safeJson(resp.body);

    if (resp.statusCode >= 400) {
      _throwFromHttp(
        resp,
        decoded,
        fallback:
            'Invalid reset code',
      );
    }

    return ForgotMessageResponse.fromJson(
      decoded,
    );
  }

  // ================= UPDATE PASSWORD =================

  Future<ForgotMessageResponse>
      updatePassword({
    required String email,
    required String code,
    required String newPassword,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri(
      '/api/users/update-password',
      query: {
        'ownerProjectLinkId':
            ownerProjectLinkId.toString(),
      },
    );

    debugPrint(
      '🔁 UPDATE PASSWORD → $uri',
    );

    final resp = await _safePost(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
       
      }),
    );

    final decoded = _safeJson(resp.body);

    if (resp.statusCode >= 400) {
      _throwFromHttp(
        resp,
        decoded,
        fallback:
            'Failed to update password',
      );
    }

    return ForgotMessageResponse.fromJson(
      decoded,
    );
  }

  // ================= HELPERS =================

  Future<http.Response> _safePost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await _client
          .post(
            uri,
            headers: headers,
            body: body,
          )
          .timeout(
            const Duration(
              seconds: 30,
            ),
          );
    } on SocketException catch (e) {
      throw NetworkException(
        'No internet connection',
        original: e,
      );
    } on TimeoutException catch (e) {
      throw NetworkException(
        'Request timed out',
        original: e,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'Network error',
        original: e,
      );
    }
  }

  Map<String, dynamic> _safeJson(
    String body,
  ) {
    if (body.isEmpty) return {};

    try {
      final decoded = jsonDecode(body);

      if (decoded
          is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  String? _extractMessage(
    Map<String, dynamic> json,
  ) {
    final m = json['message'];
    final e = json['error'];

    if (m is String &&
        m.trim().isNotEmpty) {
      return m;
    }

    if (e is String &&
        e.trim().isNotEmpty) {
      return e;
    }

    return null;
  }

  Never _throwFromHttp(
    http.Response resp,
    Map<String, dynamic> decoded, {
    required String fallback,
  }) {
    final msg =
        _extractMessage(decoded);

    final status =
        resp.statusCode;

    final finalMsg =
        msg ??
        () {
          switch (status) {
            case 400:
              return 'Invalid request.';
            case 401:
              return 'Unauthorized.';
            case 403:
              return 'No permission.';
            case 404:
              return 'User not found.';
            case 409:
              return 'Conflict.';
            case 422:
              return 'Invalid fields.';
            case 500:
              return 'Server error.';
            default:
              return fallback;
          }
        }();

    throw AuthException(
      finalMsg,
      original: resp,
    );
  }
}