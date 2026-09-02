import 'package:equatable/equatable.dart';

/// Base class for all application-level failures.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => <Object?>[message, code];
}

class CameraFailure extends Failure {
  const CameraFailure({required super.message, super.code});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

class AudioFailure extends Failure {
  const AudioFailure({required super.message, super.code});
}

class OcrFailure extends Failure {
  const OcrFailure({required super.message, super.code});
}

class PdfGenerationFailure extends Failure {
  const PdfGenerationFailure({required super.message, super.code});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
