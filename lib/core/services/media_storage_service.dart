import 'dart:io';

import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Stores media files on local device storage.
class MediaStorageService {
  MediaStorageService({Uuid uuid = const Uuid()}) : _uuid = uuid;

  final Uuid _uuid;

  Future<Result<Directory>> mediaDirectory() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'media'));
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return Success<Directory>(dir);
    } on Object catch (error) {
      return Error<Directory>(
        StorageFailure(message: 'Failed to access media directory: $error'),
      );
    }
  }

  Future<Result<String>> saveBytes({
    required List<int> bytes,
    required String extension,
    String? subfolder,
  }) async {
    final dirResult = await mediaDirectory();
    if (dirResult.isFailure) {
      return Error<String>(dirResult.failureOrNull!);
    }

    try {
      final folder = subfolder == null
          ? dirResult.valueOrNull!
          : Directory(p.join(dirResult.valueOrNull!.path, subfolder))
            ..createSync(recursive: true);
      final fileName = '${_uuid.v4()}.$extension';
      final file = File(p.join(folder.path, fileName));
      await file.writeAsBytes(bytes);
      return Success<String>(file.path);
    } on Object catch (error) {
      return Error<String>(
        StorageFailure(message: 'Failed to save file: $error'),
      );
    }
  }

  Future<Result<String>> copyToMedia({
    required String sourcePath,
    required String extension,
  }) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();
      return await saveBytes(bytes: bytes, extension: extension);
    } on Object catch (error) {
      return Error<String>(
        StorageFailure(message: 'Failed to copy file: $error'),
      );
    }
  }
}
