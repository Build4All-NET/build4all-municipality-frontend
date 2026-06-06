import 'package:flutter/material.dart';

/// A pulsing placeholder box for skeleton loading UIs.
///
/// Uses its own [AnimationController] so no wrapper is required.
/// Multiple [ShimmerBox] instances built in the same frame share the same
/// pulse phase because they all start at 0 simultaneously.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  /// Override the shimmer colors — useful on coloured backgrounds
  /// (e.g. the primary-gradient home header).
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFDFDFDF));
    final highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF4D4D4D) : const Color(0xFFF4F4F4));

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(base, highlight, _ctrl.value),
        ),
      ),
    );
  }
}
