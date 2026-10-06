// RTL: layout must follow the locale's direction instead of hard-coding left/right.

import 'dart:io';

import 'package:baladiyati/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Finder languageSelector() =>
      find.byWidgetPredicate((w) => w.runtimeType.toString() == '_LanguageSelector');

  testWidgets('welcome language selector sits at the start edge: right in Arabic', (tester) async {
    setScreenSize(tester, phoneSize);
    await tester.pumpWidget(testApp(const WelcomeScreen(), locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(WelcomeScreen))), TextDirection.rtl);
    expect(tester.getCenter(languageSelector()).dx, greaterThan(phoneSize.width / 2));
  });

  testWidgets('welcome language selector mirrors to the left in English', (tester) async {
    setScreenSize(tester, phoneSize);
    await tester.pumpWidget(testApp(const WelcomeScreen(), locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(WelcomeScreen))), TextDirection.ltr);
    expect(tester.getCenter(languageSelector()).dx, lessThan(phoneSize.width / 2));
  });

  test('no direction-blind layout code creeps back into lib/', () {
    final banned = <RegExp, String>{
      RegExp(r'EdgeInsets\.only\([^)]*\b(left|right):'): 'use EdgeInsetsDirectional.only(start/end)',
      RegExp(r'isRtl\s*\?\s*CrossAxisAlignment'): 'CrossAxisAlignment.start is already direction-aware',
      RegExp(r'isRtl\s*\?\s*TextAlign'): 'use TextAlign.start',
      RegExp(r'textAlign:\s*TextAlign\.right'): 'use TextAlign.start (Latin-only inputs may use TextAlign.left)',
      RegExp(r'Positioned\(\s*[^)]*\b(left|right):'): 'use PositionedDirectional(start/end)',
    };
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.contains('app_localizations')) continue;
      final src = f.readAsStringSync();
      for (final e in banned.entries) {
        for (final m in e.key.allMatches(src)) {
          // Stretching a Positioned edge to edge (left: 0, right: 0) is direction-neutral.
          final text = m.group(0)!;
          if (text.startsWith('Positioned') && RegExp(r'left:\s*\d+(\.\d+)?,\s*right:\s*\d+(\.\d+)?').hasMatch(src.substring(m.start, (m.end + 80).clamp(0, src.length)))) {
            continue;
          }
          offenders.add('${f.path}: ${e.value}');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
