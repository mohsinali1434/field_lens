/// Optional speech-to-text abstraction for voice notes.
abstract class SpeechToTextService {
  Future<String> transcribe(String audioPath);
}

/// Local placeholder until a Whisper integration is available.
class LocalSpeechToTextService implements SpeechToTextService {
  @override
  Future<String> transcribe(String audioPath) async {
    return '';
  }
}
