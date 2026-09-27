// lib/core/config/app_file_types.dart

import 'package:mime/mime.dart';

/// Single source of truth for the file formats the app accepts, previews and uploads.
class AppFileTypes {
  /// Image formats every target (Android, iOS and web browsers) can decode and preview.
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];

  /// Document formats accepted as request attachments.
  static const List<String> documentExtensions = ['pdf', 'doc', 'docx'];

  /// Everything a citizen may attach to a request.
  static const List<String> attachmentExtensions = [...documentExtensions, ...imageExtensions];

  /// Fallback MIME type when the format can't be detected.
  static const String fallbackMimeType = 'application/octet-stream';

  /// Lower-case extension without the dot ("photo.JPG" -> "jpg"); ignores query strings.
  static String extensionOf(String fileName) {
    final clean = fileName.split('?').first;
    final dot = clean.lastIndexOf('.');
    if (dot < 0 || dot == clean.length - 1) return '';
    return clean.substring(dot + 1).toLowerCase();
  }

  static bool isImage(String fileName) => imageExtensions.contains(extensionOf(fileName));

  static bool isPdf(String fileName) => extensionOf(fileName) == 'pdf';

  /// MIME type from the file name, falling back to the file's magic bytes.
  static String mimeTypeOf(String fileName, {List<int>? headerBytes}) =>
      lookupMimeType(fileName, headerBytes: headerBytes) ?? fallbackMimeType;
}
