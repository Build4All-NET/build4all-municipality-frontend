import 'dart:typed_data';

import 'package:baladiyati/core/config/app_file_types.dart';
import 'package:baladiyati/core/utils/picked_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFileTypes', () {
    test('extensionOf is case-insensitive and ignores query strings', () {
      expect(AppFileTypes.extensionOf('Photo.JPG'), 'jpg');
      expect(AppFileTypes.extensionOf('/uploads/a.webp?v=2'), 'webp');
      expect(AppFileTypes.extensionOf('no_extension'), '');
    });

    test('recognises web image formats', () {
      for (final name in ['a.jpg', 'a.jpeg', 'a.png', 'a.gif', 'a.webp', 'a.bmp']) {
        expect(AppFileTypes.isImage(name), isTrue, reason: name);
      }
      expect(AppFileTypes.isImage('a.pdf'), isFalse);
    });

    test('attachments accept documents and images', () {
      expect(AppFileTypes.attachmentExtensions, containsAll(['pdf', 'docx', 'webp', 'png']));
    });
  });

  group('PickedFileData', () {
    final bytes = Uint8List.fromList([1, 2, 3]);

    test('detects MIME type from the file name', () {
      expect(PickedFileData(name: 'x.webp', bytes: bytes).mimeType, 'image/webp');
      expect(PickedFileData(name: 'x.pdf', bytes: bytes).mimeType, 'application/pdf');
      expect(PickedFileData(name: 'x.unknown', bytes: bytes).mimeType, AppFileTypes.fallbackMimeType);
    });

    test('builds multipart parts from memory with name and content type', () {
      final file = PickedFileData(name: 'photo.webp', bytes: bytes);

      final httpPart = file.toHttpMultipart('files');
      expect(httpPart.field, 'files');
      expect(httpPart.filename, 'photo.webp');
      expect(httpPart.contentType.mimeType, 'image/webp');
      expect(httpPart.length, bytes.length);

      final dioPart = file.toDioMultipart();
      expect(dioPart.filename, 'photo.webp');
      expect(dioPart.contentType?.mimeType, 'image/webp');
      expect(dioPart.length, bytes.length);
    });
  });
}
