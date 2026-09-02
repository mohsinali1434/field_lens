import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success holds value', () {
      const result = Success<int>(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('Error holds failure', () {
      const failure = UnknownFailure(message: 'test');
      const result = Error<int>(failure);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('map transforms success value', () {
      const result = Success<int>(2);
      final mapped = result.map((int v) => v * 2);
      expect(mapped, isA<Success<int>>());
      expect(mapped.valueOrNull, 4);
    });

    test('map preserves error', () {
      const failure = DatabaseFailure(message: 'db error');
      const result = Error<int>(failure);
      final mapped = result.map((int v) => v * 2);
      expect(mapped, isA<Error<int>>());
      expect(mapped.failureOrNull, failure);
    });

    test('fold handles both cases', () {
      const success = Success<String>('ok');
      const error = Error<String>(UnknownFailure(message: 'fail'));

      expect(
        success.fold(
          onSuccess: (String v) => v,
          onFailure: (_) => 'error',
        ),
        'ok',
      );
      expect(
        error.fold(
          onSuccess: (String v) => v,
          onFailure: (Failure f) => f.message,
        ),
        'fail',
      );
    });
  });
}
