// lib/core/network/api_config.dart

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:baladiyati/core/config/env.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  final String municipalityBaseUrl;
  final String build4allBaseUrl;
  final Map<String, dynamic> extras;

  ApiConfig._(
    this.municipalityBaseUrl,
    this.build4allBaseUrl,
    this.extras,
  );

  static const _prefsKeyMunicipality = 'municipality_api_root';
  static const _prefsKeyBuild4all = 'build4all_api_root';



// Use Env so GitHub Actions / dart-define controls URLs.
static String get _defaultMunicipality => Env.overrideBaseUrl;
static String get _defaultBuild4all => Env.apiBaseUrl;

  static Future<ApiConfig> load() async {
    String? muniFromPrefs;
    String? build4allFromPrefs;

    try {
      final sp = await SharedPreferences.getInstance();

      final m = sp.getString(_prefsKeyMunicipality);
      final b = sp.getString(_prefsKeyBuild4all);

      if (m != null && m.trim().isNotEmpty) {
        muniFromPrefs = m.trim();
      }

      if (b != null && b.trim().isNotEmpty) {
        build4allFromPrefs = b.trim();
      }
    } catch (_) {}

    Map<String, dynamic> json = {};
    String? muniFromJson;
    String? build4allFromJson;

    // Optional legacy file support.
    // If hostIp.json is deleted, this safely falls back to Env.
    try {
      final raw = await rootBundle.loadString('lib/config/hostIp.json');
      json = jsonDecode(raw) as Map<String, dynamic>;

      muniFromJson = (json['municipalityUrl'] ?? '').toString();
      build4allFromJson = (json['build4allUrl'] ?? '').toString();
    } catch (_) {}

    final municipality = _normalize(
      muniFromPrefs ?? muniFromJson ?? _defaultMunicipality,
    );

    final build4all = _normalize(
      build4allFromPrefs ?? build4allFromJson ?? _defaultBuild4all,
    );

    return ApiConfig._(
      municipality,
      build4all,
      json,
    );
  }

  static String _normalize(String input) {
    var s = input.trim();

    if (s.endsWith('/api')) {
      s = s.substring(0, s.length - 4);
    }

    s = s.replaceAll(RegExp(r'/+$'), '');

    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'http://$s';
    }

    // Android emulator fix.
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          s = s
              .replaceFirst('http://localhost', 'http://10.0.2.2')
              .replaceFirst('https://localhost', 'http://10.0.2.2');
        }
      } catch (_) {}
    }

    return s;
  }
}