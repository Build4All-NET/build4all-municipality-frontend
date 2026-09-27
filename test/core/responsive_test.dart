import 'package:baladiyati/common/widgets/responsive_center.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';
import 'package:baladiyati/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// Pumps a widget that reports the [BuildContext] responsive values at [width].
Future<BuildContext> _contextAt(WidgetTester tester, double width) async {
  setScreenSize(tester, Size(width, 900));
  late BuildContext captured;
  await tester.pumpWidget(MaterialApp(
    home: Builder(builder: (context) {
      captured = context;
      return const SizedBox();
    }),
  ));
  return captured;
}

void main() {
  group('ResponsiveContext.screenSize', () {
    final cases = <double, ScreenSize>{
      390: ScreenSize.compact,
      AppBreakpoints.medium - 1: ScreenSize.compact,
      AppBreakpoints.medium: ScreenSize.medium,
      AppBreakpoints.expanded - 1: ScreenSize.medium,
      AppBreakpoints.expanded: ScreenSize.expanded,
      1920: ScreenSize.expanded,
    };

    cases.forEach((width, expected) {
      testWidgets('width $width -> $expected', (tester) async {
        final context = await _contextAt(tester, width);
        expect(context.screenSize, expected);
        expect(context.isCompact, expected == ScreenSize.compact);
        expect(context.isExpanded, expected == ScreenSize.expanded);
      });
    });
  });

  group('ResponsiveContext.responsive', () {
    testWidgets('larger sizes fall back to the nearest smaller value', (tester) async {
      final context = await _contextAt(tester, 1440);
      expect(context.responsive(compact: 1), 1);
      expect(context.responsive(compact: 1, medium: 2), 2);
      expect(context.responsive(compact: 1, medium: 2, expanded: 3), 3);
    });

    testWidgets('grid columns follow AppLayout per size', (tester) async {
      expect((await _contextAt(tester, 390)).gridColumns, AppLayout.gridColumnsCompact);
      expect((await _contextAt(tester, 800)).gridColumns, AppLayout.gridColumnsMedium);
      expect((await _contextAt(tester, 1440)).gridColumns, AppLayout.gridColumnsExpanded);
    });
  });

  group('ResponsiveCenter', () {
    const childKey = Key('content');

    Future<double> childWidth(WidgetTester tester, Size screen, Widget center) async {
      setScreenSize(tester, screen);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: center)));
      return tester.getSize(find.byKey(childKey)).width;
    }

    testWidgets('fills the full width on phones', (tester) async {
      final width = await childWidth(
        tester,
        phoneSize,
        const ResponsiveCenter(child: SizedBox.expand(key: childKey)),
      );
      expect(width, phoneSize.width);
    });

    testWidgets('caps width on desktop and centers the content', (tester) async {
      final width = await childWidth(
        tester,
        desktopSize,
        const ResponsiveCenter(child: SizedBox.expand(key: childKey)),
      );
      expect(width, AppLayout.maxWidthPage);
      final left = tester.getTopLeft(find.byKey(childKey)).dx;
      expect(left, (desktopSize.width - AppLayout.maxWidthPage) / 2);
    });

    testWidgets('named constructors use their AppLayout widths', (tester) async {
      expect(
        await childWidth(tester, desktopSize, const ResponsiveCenter.auth(child: SizedBox.expand(key: childKey))),
        AppLayout.maxWidthAuth,
      );
      expect(
        await childWidth(tester, desktopSize, const ResponsiveCenter.form(child: SizedBox.expand(key: childKey))),
        AppLayout.maxWidthForm,
      );
      expect(
        await childWidth(tester, desktopSize, const ResponsiveCenter.detail(child: SizedBox.expand(key: childKey))),
        AppLayout.maxWidthDetail,
      );
    });

    testWidgets('keeps a scrollable child scrollable', (tester) async {
      setScreenSize(tester, desktopSize);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResponsiveCenter(
            child: ListView(
              children: List.generate(50, (i) => SizedBox(height: 80, child: Text('row $i'))),
            ),
          ),
        ),
      ));
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.text('row 0'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
