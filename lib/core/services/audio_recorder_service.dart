import 'dart:io';

import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

/// Records voice notes to local storage.
class AudioRecorderService {
  AudioRecorderService({
    AudioRecorder? recorder,
    Uuid uuid = const Uuid(),
  }) : _recorder = recorder ?? AudioRecorder(),
       _uuid = uuid;

  final AudioRecorder _recorder;
  final Uuid _uuid;
  String? _currentPath;

  Future<Result<bool>> start() async {
    try {
      if (!await _recorder.hasPermission()) {
        return const Error<bool>(
          PermissionFailure(message: 'Microphone permission denied'),
        );
      }
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(p.join(dir.path, 'audio'));
      if (!audioDir.existsSync()) {
        await audioDir.create(recursive: true);
      }
      _currentPath = p.join(audioDir.path, '${_uuid.v4()}.m4a');
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentPath!,
      );
      return const Success<bool>(true);
    } on Object catch (error) {
      return Error<bool>(AudioFailure(message: 'Recording failed: $error'));
    }
  }

  Future<Result<String>> stop() async {
    try {
      final path = await _recorder.stop();
      if (path == null) {
        return const Error<String>(AudioFailure(message: 'No recording found'));
      }
      return Success<String>(path);
    } on Object catch (error) {
      return Error<String>(AudioFailure(message: 'Stop failed: $error'));
    }
  }

  Future<void> dispose() => _recorder.dispose();
}
