import 'package:equatable/equatable.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';

/// Generated inspection report metadata.
class ReportEntity extends Equatable {
  const ReportEntity({
    required this.id,
    required this.inspectionId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.filePath,
    this.generatedAt,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String inspectionId;
  final ReportStatus status;
  final String? filePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? generatedAt;
  final SyncMetadata sync;

  @override
  List<Object?> get props => <Object?>[
    id,
    inspectionId,
    status,
    filePath,
    createdAt,
    updatedAt,
    generatedAt,
    sync,
  ];
}
