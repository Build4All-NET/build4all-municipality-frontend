// lib/core/utils/picked_file.dart

import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_file_types.dart';

/// A file chosen by the user, held in memory.
///
/// Uses bytes instead of `dart:io` [File] paths so the same code works on
/// Android, iOS and web (browsers don't expose file-system paths).
class PickedFileData {
  final String name;
  final Uint8List bytes;

  /// Original platform path when one exists (a blob URL on web). Informational only.
  final String? path;

  const PickedFileData({required this.name, required this.bytes, this.path});

  String get mimeType => AppFileTypes.mimeTypeOf(name, headerBytes: bytes);
  bool get isImage => AppFileTypes.isImage(name);

  /// From image_picker (camera / gallery). Works on every platform.
  static Future<PickedFileData> fromXFile(XFile file) async {
    return PickedFileData(name: file.name, bytes: await file.readAsBytes(), path: file.path);
  }

  /// From file_picker. Callers must pick with `withData: true` so bytes are
  /// available on every platform; returns null when they are missing.
  static PickedFileData? fromPlatformFile(PlatformFile file) {
    final bytes = file.bytes;
    if (bytes == null) return null;
    // PlatformFile.path throws on web, so it is only read on other platforms.
    return PickedFileData(name: file.name, bytes: bytes, path: kIsWeb ? null : file.path);
  }

  /// Multipart part for Dio uploads.
  dio.MultipartFile toDioMultipart() => dio.MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: MediaType.parse(mimeType),
      );

  /// Multipart part for `package:http` uploads.
  http.MultipartFile toHttpMultipart(String field) => http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: name,
        contentType: MediaType.parse(mimeType),
      );
}
