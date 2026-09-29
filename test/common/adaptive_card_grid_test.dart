import 'package:baladiyati/common/widgets/adaptive_card_grid.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

List<Widget> _cards(int count) =>
    List.generate(count, (i) => SizedBox(key: ValueKey('card$i'), height: 80));

void main() {
  test('adaptiveCardColumns: one column on phones, capped on huge screens', () {
    expect(adaptiveCardColumns(phoneSize.width), 1);
    expect(adaptiveCardColumns(AppLayout.cardMinWidth * 2 + AppLayout.cardGridSpacing), 2);
    expect(adaptiveCardColumns(10000), AppLayout.cardMaxColumns);
  });

  testWidgets('AdaptiveCardGrid stacks cards on phones', (tester) async {
    setScreenSize(tester, phoneSize);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: AdaptiveCardGrid(children: _cards(3)))),
    ));

    expect(tester.getSize(find.byKey(const ValueKey('card0'))).width, phoneSize.width);
    expect(tester.getTopLeft(find.byKey(const ValueKey('card1'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const ValueKey('card0'))).dy));
  });

  testWidgets('AdaptiveCardGrid puts cards side by side on desktop', (tester) async {
    setScreenSize(tester, desktopSize);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: AdaptiveCardGrid(children: _cards(3)))),
    ));

    final first = tester.getRect(find.byKey(const ValueKey('card0')));
    final second = tester.getRect(find.byKey(const ValueKey('card1')));
    final third = tester.getRect(find.byKey(const ValueKey('card2')));
    expect(first.top, second.top);
    expect(first.width, second.width);
    // The last row keeps the same card width even when it isn't full.
    expect(third.width, first.width);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdaptiveCardList builds every item in rows', (tester) async {
    setScreenSize(tester, desktopSize);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AdaptiveCardList.builder(
          itemCount: 5,
          itemBuilder: (_, i) => Text('item $i'),
        ),
      ),
    ));

    for (var i = 0; i < 5; i++) {
      expect(find.text('item $i'), findsOneWidget);
    }
  });
}
