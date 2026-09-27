import 'dart:io';
import 'dart:typed_data';

import 'package:baladiyati/core/utils/file_store/file_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The mobile (dart:io) FileStore; path_provider is pointed at temp folders.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory documentsDir;
  late Directory tempDir;
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    documentsDir = Directory.systemTemp.createTempSync('docs_');
    tempDir = Directory.systemTemp.createTempSync('tmp_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
          return documentsDir.path;
        case 'getTemporaryDirectory':
          return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    documentsDir.deleteSync(recursive: true);
    tempDir.deleteSync(recursive: true);
  });

  final bytes = Uint8List.fromList(List.generate(64, (i) => i));

  test('find returns null before the file is saved', () async {
    expect(await const FileStore().find('certificate_1.pdf'), isNull);
  });

  test('save writes the bytes and find / read / exists see them', () async {
    const store = FileStore();
    final handle = await store.save('certificate_1.pdf', bytes);

    expect(handle, '${documentsDir.path}/certificate_1.pdf');
    expect(await store.find('certificate_1.pdf'), handle);
    expect(await store.exists(handle), isTrue);
    expect(await store.read(handle), bytes);
  });

  test('temporary store writes to the temp directory', () async {
    final handle = await const FileStore(temporary: true).save('receipt_7.pdf', bytes);
    expect(handle, '${tempDir.path}/receipt_7.pdf');
    expect(File(handle).readAsBytesSync(), bytes);
  });

  test('exists / read report missing files', () async {
    const store = FileStore();
    final missing = '${documentsDir.path}/missing.pdf';
    expect(await store.exists(missing), isFalse);
    expect(await store.read(missing), isNull);
  });
}
