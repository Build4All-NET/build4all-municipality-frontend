// lib/core/network/api_config.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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

  static const _defaultMunicipality =
  String.fromEnvironment('MUNI_API', defaultValue: 'http://10.0.2.2:8080');

  static const _defaultBuild4all =
  String.fromEnvironment('BUILD4ALL_API', defaultValue: ' https://perjury-threefold-unshipped.ngrok-free.dev');

  static Future<ApiConfig> load() async {
    String? muniFromPrefs;
    String? authFromPrefs;

    try {
      final sp = await SharedPreferences.getInstance();

      final m = sp.getString(_prefsKeyMunicipality);
      final a = sp.getString(_prefsKeyBuild4all);

      if (m != null && m.trim().isNotEmpty) {
        muniFromPrefs = m.trim();
      }

      if (a != null && a.trim().isNotEmpty) {
        authFromPrefs = a.trim();
      }
    } catch (_) {}

    Map<String, dynamic> json = {};

    String? muniFromJson;
    String? authFromJson;

    try {
      final raw = await rootBundle.loadString('../../config/hostIp.json');
      json = jsonDecode(raw) as Map<String, dynamic>;


      muniFromJson = (json['municipalityUrl'] ?? '').toString();
      authFromJson = (json['build4allUrl'] ?? '').toString();
    } catch (_) {}

    final municipality = _normalize(
      muniFromPrefs ?? muniFromJson ?? _defaultMunicipality,
    );

    final build4all = _normalize(
      authFromPrefs ?? authFromJson ?? _defaultBuild4all,
    );
    print("MUNICIPALITY URL FROM CONFIG: $municipality");
    print("BUILD4ALL URL FROM CONFIG: $build4all");
    print("RAW JSON: $json");
    return ApiConfig._(municipality, build4all, json);
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

    // Android emulator fix
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