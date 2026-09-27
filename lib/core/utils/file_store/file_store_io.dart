// lib/core/utils/file_store/file_store_io.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'file_open_result.dart';

/// Mobile / desktop implementation: files live on disk.
class FileStore {
  /// Use the OS temp directory (e.g. one-off receipts) instead of app storage.
  final bool temporary;

  const FileStore({this.temporary = false});

  Future<Directory> _directory() async {
    if (temporary) return getTemporaryDirectory();
    // Android: app-specific external storage, visible to the user's file viewer.
    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectory();
      if (external != null) return external;
    }
    return getApplicationDocumentsDirectory();
  }

  /// Handle of an already saved file, or null when it isn't saved.
  Future<String?> find(String fileName) async {
    final path = '${(await _directory()).path}/$fileName';
    return File(path).existsSync() ? path : null;
  }

  Future<bool> exists(String handle) async => File(handle).existsSync();

  Future<Uint8List?> read(String handle) async {
    final file = File(handle);
    return file.existsSync() ? file.readAsBytes() : null;
  }

  /// Saves [bytes] and returns the file's handle.
  Future<String> save(String fileName, Uint8List bytes) async {
    final path = '${(await _directory()).path}/$fileName';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  Future<FileOpenResult> open(String handle) async {
    final result = await OpenFilex.open(handle);
    return result.type == ResultType.done
        ? const FileOpenResult.done()
        : FileOpenResult.failed(result.message);
  }

  /// Saves then opens; returns the saved file's handle.
  Future<String> saveAndOpen(String fileName, Uint8List bytes) async {
    final handle = await save(fileName, bytes);
    await open(handle);
    return handle;
  }
}
