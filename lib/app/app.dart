// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/l10n/locale_cubit.dart';
import '../core/theme/theme_cubit.dart';
import '../core/theme/app_theme_builder.dart';
import '../features/auth/data/services/auth_api_service.dart';
import '../features/auth/presentation/login/bloc/auth_bloc.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthBloc(authApi: AuthApiService())),
               BlocProvider(create: (_) => ColorCubit()), // ✅ NEW

      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'بلديتي',
                debugShowCheckedModeBanner: false,
                theme: AppThemeBuilder.build(themeState.tokens),
                locale: locale ?? const Locale('ar'),
                supportedLocales: const [
                  Locale('ar'),
                  Locale('en'),
                  Locale('fr'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const WelcomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
