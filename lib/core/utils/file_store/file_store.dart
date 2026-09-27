// lib/core/utils/file_store/file_store.dart
//
// Saves downloaded files (certificates, receipts, attachments) and opens them.
//  - Android / iOS: files are written to disk and opened with the system viewer.
//  - Web: files are kept in memory for the session and opened in a new browser
//    tab (or downloaded when the browser blocks the tab).
//
// Both implementations expose the same `FileStore` API; a "handle" is the full
// path on mobile and the file name on web.

export 'file_open_result.dart';
export 'file_store_io.dart' if (dart.library.js_interop) 'file_store_web.dart';
