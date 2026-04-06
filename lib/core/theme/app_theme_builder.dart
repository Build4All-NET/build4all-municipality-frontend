// lib/core/theme/app_theme_builder.dart
// ─────────────────────────────────────────
// Builds Flutter ThemeData from AppThemeTokens
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'app_theme_tokens.dart';

class AppThemeBuilder {
  static ThemeData build(AppThemeTokens tokens) {
    final colors = tokens.colors;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.primary,
        onSecondary: colors.onPrimary,
        error: Colors.red,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.label,
      ),
      scaffoldBackgroundColor: colors.background,

      // Button style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Input style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),

      // Text style
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: colors.label, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: colors.label, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: colors.label, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: colors.label, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: colors.label, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: colors.label),
        bodyMedium: TextStyle(color: colors.body),
        bodySmall: TextStyle(color: colors.body),
      ),
    );
  }
}
