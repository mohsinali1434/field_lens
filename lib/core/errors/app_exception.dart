import 'package:field_lens/core/errors/failures.dart';

/// Wraps unexpected errors and maps them to [Failure] instances.
class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  Failure toFailure() => UnknownFailure(message: message, code: code);

  @override
  String toString() => 'AppException($message)';
}
