// lib/core/network/globals.dart
library globals;

import 'dart:convert';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/network/connecting(wifiORserver)/connection_cubit.dart';

import 'package:baladiyati/core/network/interceptors/auth_body_injector.dart';
import 'package:baladiyati/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio? appDio;

/// Core server base, e.g. "http://192.168.1.5:8080"
late String appServerRoot;

// -------- Tokens (legacy compatibility) --------
String? authToken;
String? token;
String? userToken;
String? Token;

// -------- Owner / tenant wiring --------
String? ownerProjectLinkId;
String? ownerAttachMode;
String? projectId;
String? appRole;
String? wsPath;

// -------- Branding --------
String appName = 'Build4All — Client';
String appLogoUrl = '';

final ValueNotifier<bool> aiEnabledNotifier = ValueNotifier<bool>(false);

bool get aiEnabled => aiEnabledNotifier.value;
set aiEnabled(bool v) => aiEnabledNotifier.value = v;

// -------- Connection Cubit (for server / network status) --------
ConnectionCubit? connectionCubit;

void registerConnectionCubit(ConnectionCubit cubit) {
  connectionCubit = cubit;
}

/// Read current auth token from any legacy field.
String readAuthToken() {
  return (authToken ?? token ?? userToken ?? Token ?? '').toString();
}

/// Set auth token and update Dio default headers.
/// Accepts raw jwt OR "Bearer <jwt>".
void setAuthToken(String? raw) {
  final t = (raw ?? '').trim();

  if (t.isEmpty) {
    authToken = null;
    token = null;
    userToken = null;
    Token = null;

    if (appDio != null) {
      appDio!.options.headers.remove('Authorization');
    }
    return;
  }

  final normalized = t.toLowerCase().startsWith('bearer ')
      ? t
      : 'Bearer $t';

  authToken = normalized;
  token = normalized;
  userToken = normalized;
  Token = normalized;

  if (appDio != null) {
    appDio!.options.headers['Authorization'] = normalized;
  }
}

/// Base URL without "/api" suffix, used to resolve relative URLs.
String serverRootNoApi() {
  final base = appServerRoot;
  return base.replaceFirst(RegExp(r'/api/?$'), '');
}

/// Resolve relative path against server root.
String resolveUrl(String maybeRelative) {
  final s = maybeRelative.trim();
  if (s.isEmpty) return s;

  if (s.startsWith('http://') || s.startsWith('https://')) return s;

  final base = serverRootNoApi().replaceAll(RegExp(r'/+$'), '');
  final rel = s.startsWith('/') ? s : '/$s';
  return '$base$rel';
}

String get appLogoUrlResolved => resolveUrl(appLogoUrl);

Dio dio() {
  return appDio ??= Dio(
    BaseOptions(
      baseUrl: appServerRoot,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 1),
    ),
  );
}


void makeDefaultDio(String baseUrl) {
  appServerRoot = baseUrl;

  ownerProjectLinkId = Env.ownerProjectLinkId;
  ownerAttachMode = Env.ownerAttachMode;
  projectId = Env.projectId;
  appRole = Env.appRole;
  wsPath = Env.wsPath;
  appName = Env.appName;
  appLogoUrl = Env.appLogoUrl;

  final d = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  d.interceptors.clear();

  // ✅ First: refresh interceptor (it retries with new tokens)
 d.interceptors.add(RefreshTokenInterceptor(d));

  // ✅ Then: inject ownerProjectLinkId / attach mode etc.
  d.interceptors.add(OwnerInjector());

  // ✅ Logging last
  d.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  appDio = d;

  // If token already set before init, copy it into dio headers
  final existing = readAuthToken().trim();
  if (existing.isNotEmpty) {
    d.options.headers['Authorization'] = existing;
  }
}

/* ===================== JWT helpers ===================== */

String? _rawJwt() {
  final full = readAuthToken().trim();
  if (full.isEmpty) return null;
  if (full.toLowerCase().startsWith('bearer ')) return full.substring(7).trim();
  return full;
}

Map<String, dynamic>? decodeJwtPayload() {
  try {
    final raw = _rawJwt();
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split('.');
    if (parts.length != 3) return null;

    var payload = parts[1];
    payload = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(payload));
    final map = jsonDecode(decoded);

    if (map is Map<String, dynamic>) return map;
    return null;
  } catch (_) {
    return null;
  }
}

String? getOwnerNameFromJwt() {
  final payload = decodeJwtPayload();
  if (payload == null) return null;

  final roleRaw = payload['role'];
  final role = roleRaw is String ? roleRaw.toUpperCase().trim() : null;

  if (role == 'OWNER') {
    final uname = payload['username'];
    if (uname is String && uname.trim().isNotEmpty) return uname.trim();
  }
  return null;
}