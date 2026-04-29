import 'package:flutter/material.dart';
import 'app_theme_tokens.dart';

class AppThemeBuilder {
  static ThemeData build(AppThemeTokens tokens) {
    final colors = tokens.colors;
    final button = tokens.button;
    final card = tokens.card;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.primary,
      onSecondary: colors.onPrimary,
      surface: colors.surface,
      error: colors.error,
      onError: colors.onPrimary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.label,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: Size.fromHeight(button.height),
          textStyle: TextStyle(
            fontSize: button.textSize,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(button.radius),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),

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