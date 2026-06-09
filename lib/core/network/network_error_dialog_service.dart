
import 'package:flutter/material.dart';

import 'navigation/app_navigator.dart';

class NetworkErrorDialogService {
  static bool _isShowing = false;

  static Future<void> showBlocking({
    required String title,
    required String message,
    required Future<bool> Function() onRetryCheck,
  }) async {
    final context = AppNavigator.context;

    if (context == null || _isShowing) {
      return;
    }

    _isShowing = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false, 
        useRootNavigator: true,
        builder: (dialogContext) {
          bool retrying = false;

          return PopScope(
            canPop: false, 
            child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded),
                      const SizedBox(width: 10),
                      Expanded(child: Text(title)),
                    ],
                  ),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: retrying
                          ? null
                          : () async {
                              setState(() => retrying = true);

                              final isBackOnline = await onRetryCheck();

                              setState(() => retrying = false);

                              if (isBackOnline && dialogContext.mounted) {
                                Navigator.of(
                                  dialogContext,
                                  rootNavigator: true,
                                ).pop();
                              }

                             
                            },
                      child: retrying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Retry'),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    } finally {
      _isShowing = false;
    }
  }
}