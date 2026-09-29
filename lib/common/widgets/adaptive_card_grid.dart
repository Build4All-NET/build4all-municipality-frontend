// lib/common/widgets/adaptive_card_grid.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';

/// Number of card columns that fit in [width]: one on phones, more on web.
int adaptiveCardColumns(double width) {
  final columns = ((width + AppLayout.cardGridSpacing) /
          (AppLayout.cardMinWidth + AppLayout.cardGridSpacing))
      .floor();
  return columns.clamp(1, AppLayout.cardMaxColumns);
}

/// Lays list cards out in equal-width columns when there is room (web / tablet)
/// and as a single column on phones, so wide screens don't show stretched,
/// mostly empty cards. Cards keep their own vertical margins.
class AdaptiveCardGrid extends StatelessWidget {
  final List<Widget> children;

  const AdaptiveCardGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = adaptiveCardColumns(constraints.maxWidth);
        if (columns == 1) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var start = 0; start < children.length; start += columns)
              _CardRow(
                columns: columns,
                children: children.sublist(start, (start + columns).clamp(0, children.length)),
              ),
          ],
        );
      },
    );
  }
}

/// Lazy version of [AdaptiveCardGrid] for long, scrollable lists.
class AdaptiveCardList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;

  const AdaptiveCardList.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = padding?.resolve(Directionality.of(context)).horizontal ?? 0;
        final columns = adaptiveCardColumns(constraints.maxWidth - horizontalPadding);
        final rowCount = (itemCount / columns).ceil();
        return ListView.builder(
          padding: padding,
          physics: physics,
          controller: controller,
          shrinkWrap: shrinkWrap,
          itemCount: rowCount,
          itemBuilder: (context, row) {
            final start = row * columns;
            final end = (start + columns).clamp(0, itemCount);
            if (columns == 1) return itemBuilder(context, start);
            return _CardRow(
              columns: columns,
              children: [for (var i = start; i < end; i++) itemBuilder(context, i)],
            );
          },
        );
      },
    );
  }
}

class _CardRow extends StatelessWidget {
  final int columns;
  final List<Widget> children;

  const _CardRow({required this.columns, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) const SizedBox(width: AppLayout.cardGridSpacing),
          // Empty slots keep the last row's cards the same width as the others.
          Expanded(child: i < children.length ? children[i] : const SizedBox.shrink()),
        ],
      ],
    );
  }
}
