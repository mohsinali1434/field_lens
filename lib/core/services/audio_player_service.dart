import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:just_audio/just_audio.dart';

/// Plays locally stored audio files.
class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Future<Result<void>> play(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
      return const Success<void>(null);
    } on Object catch (error) {
      return Error<void>(AudioFailure(message: 'Playback failed: $error'));
    }
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}
