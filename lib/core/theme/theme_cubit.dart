import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/env.dart';
import 'app_theme_builder.dart';
import 'app_theme_tokens.dart';
import 'remote_theme_dto.dart';

class ThemeState {
  final ThemeData themeData;
  final AppThemeTokens tokens;
  final bool isLoaded;
  final String menuType;

  const ThemeState({
    required this.themeData,
    required this.tokens,
    required this.isLoaded,
    required this.menuType,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    AppThemeTokens? tokens,
    bool? isLoaded,
    String? menuType,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      tokens: tokens ?? this.tokens,
      isLoaded: isLoaded ?? this.isLoaded,
      menuType: menuType ?? this.menuType,
    );
  }

  factory ThemeState.initial() {
    final tokens = AppThemeTokens.fallback();

    return ThemeState(
      themeData: AppThemeBuilder.build(tokens),
      tokens: tokens,
      isLoaded: false,
      menuType: 'bottom',
    );
  }
}

class ColorCubit extends Cubit<Color> {
  ColorCubit() : super(const Color.fromRGBO(33, 54, 243, 0.884));

  void changeColor(Color color) {
    emit(color);
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial()) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final envB64 = Env.themeJsonB64.trim();

    if (envB64.isEmpty) {
      emit(state.copyWith(isLoaded: true));
      return;
    }

    try {
      final remote = RemoteThemeDto.fromBase64Json(envB64);
      final tokens = AppThemeTokens.fromRemote(remote);
      final themeData = AppThemeBuilder.build(tokens);

      emit(
        state.copyWith(
          themeData: themeData,
          tokens: tokens,
          isLoaded: true,
          menuType: (remote.menuType ?? 'bottom').toLowerCase(),
        ),
      );

      debugPrint('Theme applied from THEME_JSON_B64');
    } catch (e) {
      debugPrint('Theme apply failed: $e');
      emit(state.copyWith(isLoaded: true));
    }
  }
}