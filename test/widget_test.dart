// Smoke test: the welcome screen renders on phone, tablet and desktop widths
// without layout errors, and its content is capped on wide screens.

import 'package:baladiyati/common/widgets/responsive_center.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';
import 'package:baladiyati/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final size in [phoneSize, tabletSize, desktopSize]) {
    testWidgets('WelcomeScreen renders at ${size.width.toInt()}px', (tester) async {
      setScreenSize(tester, size);
      await tester.pumpWidget(testApp(const WelcomeScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The capped column is the first SizedBox inside ResponsiveCenter.
      final content = tester.getSize(find
          .descendant(of: find.byType(ResponsiveCenter), matching: find.byType(SizedBox))
          .first);
      expect(content.width, lessThanOrEqualTo(AppLayout.maxWidthAuth));
    });
  }
}
