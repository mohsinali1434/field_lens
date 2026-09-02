import 'package:equatable/equatable.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';

/// Domain representation of an inspection observation.
class ObservationEntity extends Equatable {
  const ObservationEntity({
    required this.id,
    required this.inspectionId,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.dueDate,
    this.assignedTo,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String inspectionId;
  final String title;
  final String description;
  final ObservationCategory category;
  final ObservationSeverity severity;
  final ObservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;
  final DateTime? dueDate;
  final String? assignedTo;
  final SyncMetadata sync;

  @override
  List<Object?> get props => <Object?>[
    id,
    inspectionId,
    title,
    description,
    category,
    severity,
    status,
    createdAt,
    updatedAt,
    latitude,
    longitude,
    dueDate,
    assignedTo,
    sync,
  ];
}
