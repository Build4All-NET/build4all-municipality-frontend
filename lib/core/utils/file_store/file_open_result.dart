// lib/core/utils/file_store/file_open_result.dart

/// Outcome of asking the platform to open a saved file.
class FileOpenResult {
  final bool success;
  final String? message;

  const FileOpenResult.done() : success = true, message = null;
  const FileOpenResult.failed([this.message]) : success = false;
}
