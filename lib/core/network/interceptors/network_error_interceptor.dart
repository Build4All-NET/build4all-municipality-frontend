import 'dart:io';

import 'package:baladiyati/core/network/network_error_dialog_service.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

class NetworkErrorInterceptor extends Interceptor {
  bool _isConnectionProblem(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.error is SocketException;
  }

  bool _isServerUnavailable(DioException err) {
    final status = err.response?.statusCode ?? 0;
    return status == 502 || status == 503 || status == 504;
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isConnectionProblem(err)) {
      await NetworkErrorDialogService.showBlocking(
        title: AppStrings.current.networkNoInternet,
        message: AppStrings.current.errReconnectHint,
        onRetryCheck: _hasInternet,
      );
    } else if (_isServerUnavailable(err)) {
      await NetworkErrorDialogService.showBlocking(
        title: AppStrings.current.errServerUnavailable,
        message: AppStrings.current.errServerUnreachableHint,
        onRetryCheck: _hasInternet,
      );
    }

    return handler.next(err);
  }
}