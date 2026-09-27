// lib/common/widgets/responsive_center.dart

import 'package:flutter/material.dart';

import 'package:baladiyati/core/config/app_breakpoints.dart';

/// Centers [child] horizontally and caps its width so pages don't stretch
/// edge-to-edge on web / desktop. On phones it has no visible effect.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  /// Vertical alignment inside the available height (top by default, so
  /// scrollable pages keep starting at the top).
  final AlignmentGeometry alignment;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxWidthPage,
    this.alignment = Alignment.topCenter,
  });

  /// Auth screens: narrow card-like column.
  const ResponsiveCenter.auth({super.key, required this.child, this.alignment = Alignment.topCenter})
      : maxWidth = AppLayout.maxWidthAuth;

  /// Create / edit forms.
  const ResponsiveCenter.form({super.key, required this.child, this.alignment = Alignment.topCenter})
      : maxWidth = AppLayout.maxWidthForm;

  /// Detail pages, chat, settings.
  const ResponsiveCenter.detail({super.key, required this.child, this.alignment = Alignment.topCenter})
      : maxWidth = AppLayout.maxWidthDetail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fill the available width up to [maxWidth], exactly like a full-width
        // body on phones; on wide screens the extra space becomes side margins.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, maxWidth).toDouble()
            : maxWidth;
        return Align(
          alignment: alignment,
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}
