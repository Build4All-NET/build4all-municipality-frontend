import 'package:baladiyati/core/l10n/locale_cubit.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Screen sizes used across widget tests (logical pixels).
const Size phoneSize = Size(390, 844);
const Size tabletSize = Size(800, 1000);
const Size desktopSize = Size(1440, 900);

/// Sets the test window to [size] and restores it when the test ends.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Wraps [child] in a MaterialApp with the app's localizations and locale cubit.
Widget testApp(Widget child, {Locale locale = const Locale('en')}) {
  return BlocProvider(
    create: (_) => LocaleCubit(),
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}
