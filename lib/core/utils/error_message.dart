import 'dart:io';

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

String errorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }

  if (error is DioException) {
    final inner = error.error;

    if (inner is AppException) {
      return inner.message;
    }

    if (inner is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AppStrings.current.errNoInternet;
    }

    final data = error.response?.data;

    if (data is Map) {
      return (data['message'] ??
              data['error'] ??
              AppStrings.current.errSomethingWrong)
          .toString();
    }

    return AppStrings.current.errSomethingWrong;
  }

  final text = error.toString();

  if (text.contains('DioException') ||
      text.contains('SocketException') ||
      text.contains('Connection failed') ||
      text.contains('Network is unreachable') ||
      text.contains('Failed host lookup')) {
    return AppStrings.current.errNoInternet;
  }

  return text.replaceAll('Exception:', '').trim();
}