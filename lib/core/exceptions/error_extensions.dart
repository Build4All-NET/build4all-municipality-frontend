// lib/core/exceptions/error_extensions.dart
import 'app_exception.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

extension UserMessageX on Object {
  String get userMessage => this is AppException
      ? (this as AppException).message
      : AppStrings.current.errSomethingWrong;
}
