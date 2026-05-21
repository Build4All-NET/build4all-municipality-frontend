import 'dart:io';

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:dio/dio.dart';

class AppErrorInterceptor extends Interceptor {
  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.error is SocketException;
  }

  String _messageFromResponse(DioException err) {
    final data = err.response?.data;

    if (data is Map) {
      return (data['message'] ??
              data['error'] ??
              data['details'] ??
              'Something went wrong.')
          .toString();
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return 'Something went wrong.';
  }

  String _codeFromResponse(DioException err) {
    final data = err.response?.data;

    if (data is Map && data['code'] != null) {
      return data['code'].toString();
    }

    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      return 'AUTH_ERROR';
    }

    return 'REQUEST_FAILED';
  }

  bool _isAuthError(int status) {
    return status == 401 || status == 403;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    if (_isNetworkError(err)) {
      appException = AppException(
        'No internet connection. Please check your Wi-Fi or mobile data.',
        code: 'NETWORK_ERROR',
        original: err,
      );
    } else {
      final status = err.response?.statusCode ?? 0;

      if (status == 500) {
        appException = AppException(
          'Server error. Please try again later.',
          code: 'SERVER_ERROR',
          original: err,
        );
      } else if (_isAuthError(status)) {
        /*
          IMPORTANT:
          Do NOT hardcode "Your session expired" here.

          RefreshTokenInterceptor runs before this interceptor.
          So if we reach this point, either:
          - refresh was not possible,
          - refresh failed,
          - or backend rejected the request for a real auth/permission reason.

          Therefore we keep the backend message if available.
        */
        final message = _messageFromResponse(err);
        final code = _codeFromResponse(err);

        appException = AppException(
          message == 'Something went wrong.'
              ? 'Authentication failed. Please login again.'
              : message,
          code: code,
          original: err,
        );
      } else {
        appException = AppException(
          _messageFromResponse(err),
          code: _codeFromResponse(err),
          original: err,
        );
      }
    }

    final cleanError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: appException,
      stackTrace: err.stackTrace,
      message: appException.message,
    );

    return handler.reject(cleanError);
  }
}