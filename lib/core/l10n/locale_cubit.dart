// lib/core/l10n/locale_cubit.dart
// ─────────────────────────────────────────
// Manages the app language
// Saves selected language to SharedPreferences
// Supports: Arabic, English, French
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale?> {
  static const _key = 'app_locale';

  LocaleCubit() : super(null) {
    _loadSaved();
  }

  // Load saved language from device
  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_key);
    if (code == null || code.isEmpty) return;
    emit(Locale(code));
  }

  // Change language and save it
  Future<void> setLocale(Locale? locale) async {
    emit(locale);
    final sp = await SharedPreferences.getInstance();
    if (locale == null) {
      await sp.remove(_key);
    } else {
      await sp.setString(_key, locale.languageCode);
    }
  }

  // Quick helpers
  void setArabic()  => setLocale(const Locale('ar'));
  void setEnglish() => setLocale(const Locale('en'));
  void setFrench()  => setLocale(const Locale('fr'));

  String get currentLanguageCode => state?.languageCode ?? 'ar';
  bool get isArabic  => currentLanguageCode == 'ar';
  bool get isEnglish => currentLanguageCode == 'en';
  bool get isFrench  => currentLanguageCode == 'fr';
}
