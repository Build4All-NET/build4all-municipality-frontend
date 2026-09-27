// lib/core/utils/file_store/file_store_web.dart

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../config/app_file_types.dart';
import 'file_open_result.dart';

/// Web implementation: browsers have no app file system, so files are kept in
/// memory for the session and handed to the browser as blob URLs.
class FileStore {
  /// Kept for API parity with the mobile implementation; unused on web.
  final bool temporary;

  const FileStore({this.temporary = false});

  /// Files saved during this browser session, keyed by file name (the handle).
  static final Map<String, Uint8List> _session = {};

  /// Blob URLs are released after this delay, once the tab / download has read them.
  static const Duration _blobUrlLifetime = Duration(minutes: 1);

  Future<String?> find(String fileName) async =>
      _session.containsKey(fileName) ? fileName : null;

  Future<bool> exists(String handle) async => _session.containsKey(handle);

  Future<Uint8List?> read(String handle) async => _session[handle];

  Future<String> save(String fileName, Uint8List bytes) async {
    _session[fileName] = bytes;
    return fileName;
  }

  Future<FileOpenResult> open(String handle) async {
    final bytes = _session[handle];
    if (bytes == null) return const FileOpenResult.failed('File not found');

    final mimeType = AppFileTypes.mimeTypeOf(handle, headerBytes: bytes);
    final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
    final url = web.URL.createObjectURL(blob);

    // PDFs and images open in a new tab; other formats (or a blocked pop-up) download.
    final viewable = AppFileTypes.isPdf(handle) || AppFileTypes.isImage(handle);
    final tab = viewable ? web.window.open(url, '_blank') : null;
    if (tab == null) {
      (web.document.createElement('a') as web.HTMLAnchorElement)
        ..href = url
        ..download = handle
        ..click();
    }

    Future.delayed(_blobUrlLifetime, () => web.URL.revokeObjectURL(url));
    return const FileOpenResult.done();
  }

  Future<String> saveAndOpen(String fileName, Uint8List bytes) async {
    final handle = await save(fileName, bytes);
    await open(handle);
    return handle;
  }
}
