import 'app_exception.dart';

class NetworkException extends AppException {
  NetworkException(
    String message, {
    Object? original,
  }) : super(
          message,
          code: 'NETWORK_ERROR',
          original: original,
        );
}

class ServerException extends AppException {
  final int statusCode;

  ServerException(
    String message, {
    required this.statusCode,
    Object? original,
    String? code,
  }) : super(
          message,
          code: code ?? 'SERVER_ERROR',
          original: original,
        );

  @override
  String toString() => 'ServerException($statusCode, $code): $message';
}