import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';
import 'package:baladiyati/core/l10n/known_names.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppStrings.setLocale(null));

  group('AppStrings', () {
    test('follows the selected language', () {
      AppStrings.setLocale(const Locale('ar'));
      expect(AppStrings.current.errNoInternet, contains('الإنترنت'));

      AppStrings.setLocale(const Locale('en'));
      expect(AppStrings.current.errNoInternet, startsWith('No internet'));

      AppStrings.setLocale(const Locale('fr'));
      expect(AppStrings.current.errNoInternet, startsWith('Pas de connexion'));
    });

    test('falls back to Arabic for null or unsupported languages', () {
      AppStrings.setLocale(null);
      expect(AppStrings.locale, AppStrings.defaultLocale);

      AppStrings.setLocale(const Locale('de'));
      expect(AppStrings.locale, AppStrings.defaultLocale);
    });

    test('ignores the country part of a locale', () {
      AppStrings.setLocale(const Locale('en', 'US'));
      expect(AppStrings.locale, const Locale('en'));
    });
  });

  group('known names', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    final fr = lookupAppLocalizations(const Locale('fr'));

    test('translates default departments and keeps unknown names', () {
      expect(localizedDepartmentName(ar, 'Engineering'), ar.deptEngineering);
      expect(localizedDepartmentName(fr, ' Finance '), fr.deptFinance);
      expect(localizedDepartmentName(ar, 'قسم خاص'), 'قسم خاص');
    });

    test('translates default services and keeps unknown names', () {
      expect(localizedServiceName(ar, 'Building Permit'), ar.serviceBuildingPermit);
      expect(localizedServiceName(fr, 'Lease Registration'), fr.serviceLeaseRegistration);
      expect(localizedServiceName(fr, 'Custom Service'), 'Custom Service');
    });
  });

  test('AppException.toString shows only the user-facing message', () {
    expect(const AppException('رسالة', code: 'X').toString(), 'رسالة');
  });
}
