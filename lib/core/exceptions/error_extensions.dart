// lib/core/exceptions/error_extensions.dart
import 'app_exception.dart';

extension UserMessageX on Object {
  String get userMessage => this is AppException
      ? (this as AppException).message
      : 'Something went wrong. Please try again.';
}
