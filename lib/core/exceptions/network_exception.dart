// lib/core/exceptions/network_exception.dart
import 'app_exception.dart';

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.original});

  factory NetworkException.noConnection() =>
      const NetworkException('No internet connection', code: 'NO_CONNECTION');

  factory NetworkException.timeout() =>
      const NetworkException('Connection timeout', code: 'TIMEOUT');

  factory NetworkException.serverError() =>
      const NetworkException('Server error. Please try later', code: 'SERVER_ERROR');
}
// to be dynamic