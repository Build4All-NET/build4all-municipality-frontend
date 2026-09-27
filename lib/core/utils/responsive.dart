// lib/core/utils/responsive.dart

import 'package:flutter/widgets.dart';

import '../config/app_breakpoints.dart';

/// Material 3 window size classes used across the app.
enum ScreenSize { compact, medium, expanded }

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.expanded) return ScreenSize.expanded;
    if (width >= AppBreakpoints.medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isExpanded => screenSize == ScreenSize.expanded;

  /// Picks a value for the current window size; larger sizes fall back to smaller ones.
  T responsive<T>({required T compact, T? medium, T? expanded}) {
    switch (screenSize) {
      case ScreenSize.expanded:
        return expanded ?? medium ?? compact;
      case ScreenSize.medium:
        return medium ?? compact;
      case ScreenSize.compact:
        return compact;
    }
  }

  /// Default number of grid columns (dashboards, tiles) for the current window size.
  int get gridColumns => responsive(
        compact: AppLayout.gridColumnsCompact,
        medium: AppLayout.gridColumnsMedium,
        expanded: AppLayout.gridColumnsExpanded,
      );
}
