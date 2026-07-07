// lib/common/widgets/primary_button.dart

import 'package:flutter/material.dart';
import '../../core/config/app_sizes.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final resolvedBackground = backgroundColor ?? cs.primary;
    final resolvedTextColor = textColor ?? cs.onPrimary;

    return SizedBox(
      width: width ?? double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: (isLoading || !enabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedBackground,
          foregroundColor: resolvedTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          elevation: 0,
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            // Pressed state uses dynamic primary color with opacity,
            // instead of a hardcoded dark blue.
            if (states.contains(MaterialState.pressed)) {
              return resolvedBackground.withOpacity(0.85);
            }

            if (states.contains(MaterialState.disabled)) {
              return cs.outline.withOpacity(0.25);
            }

            return resolvedBackground;
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: resolvedTextColor,
                ),
              )
            : Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: resolvedTextColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}