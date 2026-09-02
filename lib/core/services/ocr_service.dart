import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts text from images using on-device OCR.
abstract class OcrService {
  Future<Result<String>> extractText(String imagePath);
}

class MlKitOcrService implements OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  @override
  Future<Result<String>> extractText(String imagePath) async {
    try {
      final input = InputImage.fromFilePath(imagePath);
      final recognized = await _recognizer.processImage(input);
      return Success<String>(recognized.text.trim());
    } on Object catch (error) {
      return Error<String>(OcrFailure(message: 'OCR failed: $error'));
    }
  }

  Future<void> dispose() => _recognizer.close();
}
