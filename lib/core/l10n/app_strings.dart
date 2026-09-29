// lib/core/l10n/app_strings.dart

import 'package:flutter/widgets.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

/// Localized strings for code that has no [BuildContext]
/// (services, repositories, error mappers, interceptors).
///
/// Widgets should keep using `AppLocalizations.of(context)`. The app keeps this
/// in sync with the selected language (see `MyApp`).
class AppStrings {
  /// Language used before the user picks one; matches the app's default locale.
  static const Locale defaultLocale = Locale('ar');

  static Locale _locale = defaultLocale;

  static Locale get locale => _locale;

  /// Called whenever the app language changes.
  static void setLocale(Locale? locale) {
    final candidate = locale ?? defaultLocale;
    _locale = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == candidate.languageCode,
    )
        ? Locale(candidate.languageCode)
        : defaultLocale;
  }

  /// Strings in the current app language.
  static AppLocalizations get current => lookupAppLocalizations(_locale);
}
