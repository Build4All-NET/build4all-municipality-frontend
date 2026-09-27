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
        SideNav(currentIndex: 1, onTap: (i) => tapped = i, extended: true),
      ]),
    )));
    await tester.pumpAndSettle();

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.destinations.length, _labels.length);
    expect(rail.selectedIndex, 1);
    expect(rail.extended, isTrue);
    for (final label in _labels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await tester.tap(find.text('Account'));
    expect(tapped, 4);
  });

  testWidgets('citizenNavItems keeps both navs in sync', (tester) async {
    await tester.pumpWidget(testApp(Scaffold(
      body: Row(children: [SideNav(currentIndex: 0, onTap: (_) {})]),
      bottomNavigationBar: BottomNav(currentIndex: 0, onTap: (_) {}),
    )));
    await tester.pumpAndSettle();

    final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(bar.items.map((i) => i.label).toList(), _labels);
    expect(rail.destinations.map((d) => (d.label as Text).data).toList(), _labels);
  });
}
