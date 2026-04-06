// lib/core/theme/theme_cubit.dart
// ─────────────────────────────────────────
// Manages light/dark theme switching
// Saves preference to SharedPreferences
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme_tokens.dart';

class ThemeState {
  final AppThemeTokens tokens;
  final bool isDark;

  const ThemeState({required this.tokens, required this.isDark});
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _key = 'app_theme';

  ThemeCubit()
      : super(ThemeState(
          tokens: AppThemeTokens.light(),
          isDark: false,
        )) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    final isDark = sp.getBool(_key) ?? false;
    if (isDark) {
      emit(ThemeState(tokens: AppThemeTokens.dark(), isDark: true));
    }
  }

  Future<void> toggleTheme() async {
    final newIsDark = !state.isDark;
    emit(ThemeState(
      tokens: newIsDark ? AppThemeTokens.dark() : AppThemeTokens.light(),
      isDark: newIsDark,
    ));
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, newIsDark);
  }

  Future<void> setLight() async {
    emit(ThemeState(tokens: AppThemeTokens.light(), isDark: false));
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, false);
  }

  Future<void> setDark() async {
    emit(ThemeState(tokens: AppThemeTokens.dark(), isDark: true));
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, true);
  }
}
