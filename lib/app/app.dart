// lib/app/app.dart
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import '../core/l10n/locale_cubit.dart';
import '../core/theme/theme_cubit.dart';
import '../core/theme/app_theme_builder.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => RegistrationStepCubit()),
        // ✅ AuthBloc removed from here — LoginScreen has its own via AppRouter
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
                localizationsDelegates: [
                  AppLocalizations.delegate,
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
