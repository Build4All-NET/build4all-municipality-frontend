// lib/common/widgets/app_toast.dart

import 'package:flutter/material.dart';

enum AppToastType {
  success,
  error,
  warning,
  info,
}

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
  }) {
    final cs = Theme.of(context).colorScheme;

    final Color backgroundColor = switch (type) {
      AppToastType.success => cs.primary,
      AppToastType.error => cs.error,
      AppToastType.warning => cs.tertiary,
      AppToastType.info => cs.inverseSurface,
    };

    final IconData icon = switch (type) {
      AppToastType.success => Icons.check_circle_outline,
      AppToastType.error => Icons.error_outline,
      AppToastType.warning => Icons.warning_amber_rounded,
      AppToastType.info => Icons.info_outline,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating, // ✅ fixed: was .fixed, conflicted with theme margin
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.onSurface.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: cs.onPrimary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}