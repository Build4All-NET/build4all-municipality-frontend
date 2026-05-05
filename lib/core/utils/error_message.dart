import 'dart:io';

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:dio/dio.dart';

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
      return 'No internet connection. Please check your Wi-Fi or mobile data.';
    }

    final data = error.response?.data;

    if (data is Map) {
      return (data['message'] ??
              data['error'] ??
              'Something went wrong. Please try again.')
          .toString();
    }

    return 'Something went wrong. Please try again.';
  }

  final text = error.toString();

  if (text.contains('DioException') ||
      text.contains('SocketException') ||
      text.contains('Connection failed') ||
      text.contains('Network is unreachable') ||
      text.contains('Failed host lookup')) {
    return 'No internet connection. Please check your Wi-Fi or mobile data.';
  }

  return text.replaceAll('Exception:', '').trim();
}