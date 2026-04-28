import 'package:flutter/material.dart';
import 'remote_theme_dto.dart';

Color _parseColor(String? hex, String fallback) {
  var value = (hex ?? fallback).replaceAll('#', '').trim();

  if (value.length == 6) {
    value = 'FF$value';
  }

  return Color(int.parse(value, radix: 16));
}

class AppThemeTokens {
  final AppColorTokens colors;
  final AppCardTokens card;
  final AppSearchTokens search;
  final AppButtonTokens button;

  const AppThemeTokens({
    required this.colors,
    required this.card,
    required this.search,
    required this.button,
  });

  factory AppThemeTokens.fallback() {
    return AppThemeTokens(
      colors: AppColorTokens(
        primary: _parseColor(null, '#16A34A'),
        onPrimary: _parseColor(null, '#FFFFFF'),
        background: _parseColor(null, '#FFFFFF'),
        surface: _parseColor(null, '#FFFFFF'),
        label: _parseColor(null, '#111827'),
        body: _parseColor(null, '#374151'),
        border: _parseColor(null, '#16A34A'),
        error: _parseColor(null, '#DC2626'),
        danger: _parseColor(null, '#DC2626'),
        muted: _parseColor(null, '#9CA3AF'),
        success: _parseColor(null, '#16A34A'),
      ),
      card: const AppCardTokens(
        padding: 12,
        radius: 16,
        elevation: 4,
        imageHeight: 120,
        showShadow: true,
        showBorder: true,
      ),
      search: const AppSearchTokens(
        radius: 16,
        borderWidth: 1.4,
        dense: true,
      ),
      button: const AppButtonTokens(
        radius: 16,
        height: 48,
        textSize: 15,
        fullWidth: true,
      ),
    );
  }

  factory AppThemeTokens.fromRemote(RemoteThemeDto remote) {
    final vm = remote.valuesMobile;

    final colorsMap = (vm['colors'] as Map<String, dynamic>?) ?? {};
    final cardMap = (vm['card'] as Map<String, dynamic>?) ?? {};
    final searchMap = (vm['search'] as Map<String, dynamic>?) ?? {};
    final buttonMap = (vm['button'] as Map<String, dynamic>?) ?? {};

    return AppThemeTokens(
      colors: AppColorTokens(
        primary: _parseColor(colorsMap['primary'], '#16A34A'),
        onPrimary: _parseColor(colorsMap['onPrimary'], '#FFFFFF'),
        background: _parseColor(colorsMap['background'], '#FFFFFF'),
        surface: _parseColor(colorsMap['surface'], '#FFFFFF'),
        label: _parseColor(colorsMap['label'], '#111827'),
        body: _parseColor(colorsMap['body'], '#374151'),
        border: _parseColor(colorsMap['border'], colorsMap['primary'] ?? '#16A34A'),
        error: _parseColor(colorsMap['error'], '#DC2626'),
        danger: _parseColor(colorsMap['danger'], colorsMap['error'] ?? '#DC2626'),
        muted: _parseColor(colorsMap['muted'], '#9CA3AF'),
        success: _parseColor(colorsMap['success'], '#16A34A'),
      ),
      card: AppCardTokens(
        padding: (cardMap['padding'] as num?)?.toDouble() ?? 12,
        radius: (cardMap['radius'] as num?)?.toDouble() ?? 16,
        elevation: (cardMap['elevation'] as num?)?.toDouble() ?? 4,
        imageHeight: (cardMap['imageHeight'] as num?)?.toDouble() ?? 120,
        showShadow: cardMap['showShadow'] as bool? ?? true,
        showBorder: cardMap['showBorder'] as bool? ?? true,
      ),
      search: AppSearchTokens(
        radius: (searchMap['radius'] as num?)?.toDouble() ?? 16,
        borderWidth: (searchMap['borderWidth'] as num?)?.toDouble() ?? 1.4,
        dense: searchMap['dense'] as bool? ?? true,
      ),
      button: AppButtonTokens(
        radius: (buttonMap['radius'] as num?)?.toDouble() ?? 16,
        height: (buttonMap['height'] as num?)?.toDouble() ?? 48,
        textSize: (buttonMap['textSize'] as num?)?.toDouble() ?? 15,
        fullWidth: buttonMap['fullWidth'] as bool? ?? true,
      ),
    );
  }

  factory AppThemeTokens.light() => AppThemeTokens.fallback();
  factory AppThemeTokens.dark() => AppThemeTokens.fallback();
}

class AppColorTokens {
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color label;
  final Color body;
  final Color border;
  final Color error;
  final Color danger;
  final Color muted;
  final Color success;

  const AppColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.label,
    required this.body,
    required this.border,
    required this.error,
    required this.danger,
    required this.muted,
    required this.success,
  });
}

class AppCardTokens {
  final double padding;
  final double radius;
  final double elevation;
  final double imageHeight;
  final bool showShadow;
  final bool showBorder;

  const AppCardTokens({
    required this.padding,
    required this.radius,
    required this.elevation,
    required this.imageHeight,
    required this.showShadow,
    required this.showBorder,
  });
}

class AppSearchTokens {
  final double radius;
  final double borderWidth;
  final bool dense;

  const AppSearchTokens({
    required this.radius,
    required this.borderWidth,
    required this.dense,
  });
}

class AppButtonTokens {
  final double radius;
  final double height;
  final double textSize;
  final bool fullWidth;

  const AppButtonTokens({
    required this.radius,
    required this.height,
    required this.textSize,
    required this.fullWidth,
  });
}