import 'dart:io';

import 'package:field_lens/core/services/media_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MediaStorageService service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('field_lens_media_test');
    configureFakePathProvider(tempDir.path);
    service = MediaStorageService();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saves bytes to media directory', () async {
    final result = await service.saveBytes(
      bytes: <int>[1, 2, 3, 4],
      extension: 'bin',
    );

    expect(result.isSuccess, isTrue);
    expect(File(result.valueOrNull!).existsSync(), isTrue);
  });

  test('copies file into media directory', () async {
    final source = File('${tempDir.path}/source.jpg');
    await source.writeAsBytes(<int>[9, 8, 7]);

    final result = await service.copyToMedia(
      sourcePath: source.path,
      extension: 'jpg',
    );

    expect(result.isSuccess, isTrue);
    expect(File(result.valueOrNull!).existsSync(), isTrue);
    expect(File(result.valueOrNull!).lengthSync(), 3);
  });
}
