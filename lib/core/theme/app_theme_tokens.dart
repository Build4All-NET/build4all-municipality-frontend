// lib/core/theme/app_theme_tokens.dart
// ─────────────────────────────────────────
// Design tokens — all visual values in one place
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AppThemeTokens {
  final AppColorTokens colors;
  final AppCardTokens card;

  const AppThemeTokens({
    required this.colors,
    required this.card,
  });

  // 🌞 LIGHT THEME
  factory AppThemeTokens.light() {
    return AppThemeTokens(
      colors: AppColorTokens(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        background: AppColors.background,
        surface: Colors.white,
        label: AppColors.darkBlue,
        body: Colors.grey,
        border: Colors.grey,

        // ✅ FIXED
        textSecondary: Colors.grey.shade600,
      ),
      card: const AppCardTokens(
        padding: 24,
        radius: 24,
        elevation: 4,
        showShadow: true,
        showBorder: false,
      ),
    );
  }

  // 🌚 DARK THEME
  factory AppThemeTokens.dark() {
    return AppThemeTokens(
      colors: AppColorTokens(
        primary: const Color.fromARGB(255, 31, 41, 161),
        onPrimary: Colors.white,
        background: const Color(0xFF0D1117),
        surface: const Color(0xFF161B22),
        label: Colors.white,
        body: Colors.grey,
        border: Colors.grey,

        // ✅ FIXED
        textSecondary: Colors.grey.shade400,
      ),
      card: const AppCardTokens(
        padding: 24,
        radius: 24,
        elevation: 4,
        showShadow: false,
        showBorder: true,
      ),
    );
  }
}

class AppColorTokens {
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color label;
  final Color body;
  final Color border;
  final Color textSecondary; // ✅ FIXED (non-nullable)

  const AppColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.label,
    required this.body,
    required this.border,
    required this.textSecondary,
  });
}

class AppCardTokens {
  final double padding;
  final double radius;
  final double elevation;
  final bool showShadow;
  final bool showBorder;

  const AppCardTokens({
    required this.padding,
    required this.radius,
    required this.elevation,
    required this.showShadow,
    required this.showBorder,
  });
}