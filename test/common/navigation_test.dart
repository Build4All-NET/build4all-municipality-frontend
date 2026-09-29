import 'package:baladiyati/common/widgets/app_sidebar.dart';
import 'package:baladiyati/common/widgets/bottom_nav.dart';
import 'package:baladiyati/common/widgets/side_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

// English labels from lib/l10n (navHome, navServices, navRequests, navPayments, navAccount).
const _labels = ['Home', 'Services', 'Requests', 'Payments', 'Account'];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('BottomNav shows every citizen destination and reports taps', (tester) async {
    int? tapped;
    await tester.pumpWidget(testApp(Scaffold(
      bottomNavigationBar: BottomNav(currentIndex: 0, onTap: (i) => tapped = i),
    )));
    await tester.pumpAndSettle();

    for (final label in _labels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await tester.tap(find.text('Payments'));
    expect(tapped, 3);
  });

  testWidgets('SideNav shows the same destinations as BottomNav', (tester) async {
    setScreenSize(tester, desktopSize);
    int? tapped;
    await tester.pumpWidget(testApp(Scaffold(
      body: Row(children: [
        SideNav(currentIndex: 1, onTap: (i) => tapped = i, extended: true, userName: 'Hadi Khalil'),
      ]),
    )));
    await tester.pumpAndSettle();

    final sidebar = tester.widget<AppSidebar>(find.byType(AppSidebar));
    expect(sidebar.items.map((i) => i.label).toList(), _labels);
    expect(sidebar.selectedIndex, 1);
    expect(sidebar.collapsed, isFalse);
    for (final label in _labels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Signed-in user is shown in the footer.
    expect(find.text('Hadi Khalil'), findsOneWidget);

    await tester.tap(find.text('Account'));
    expect(tapped, 4);
  });

  testWidgets('SideNav shows icons only when collapsed (tablet)', (tester) async {
    setScreenSize(tester, tabletSize);
    await tester.pumpWidget(testApp(Scaffold(
      body: Row(children: [SideNav(currentIndex: 0, onTap: (_) {})]),
    )));
    await tester.pumpAndSettle();

    expect(tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed, isTrue);
    expect(find.text('Services'), findsNothing);
    expect(find.byTooltip('Services'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('citizenNavItems keeps both navs in sync', (tester) async {
    setScreenSize(tester, desktopSize);
    await tester.pumpWidget(testApp(Scaffold(
      body: Row(children: [SideNav(currentIndex: 0, onTap: (_) {}, extended: true)]),
      bottomNavigationBar: BottomNav(currentIndex: 0, onTap: (_) {}),
    )));
    await tester.pumpAndSettle();

    final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    final sidebar = tester.widget<AppSidebar>(find.byType(AppSidebar));
    expect(bar.items.map((i) => i.label).toList(), _labels);
    expect(sidebar.items.map((i) => i.label).toList(), _labels);
  });
}
