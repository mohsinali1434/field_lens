import 'package:equatable/equatable.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';

/// Activity timeline entry for an inspection.
class TimelineEventEntity extends Equatable {
  const TimelineEventEntity({
    required this.id,
    required this.inspectionId,
    required this.eventType,
    required this.title,
    required this.description,
    required this.createdAt,
    this.metadata,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String inspectionId;
  final TimelineEventType eventType;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? metadata;
  final SyncMetadata sync;

  @override
  List<Object?> get props => <Object?>[
    id,
    inspectionId,
    eventType,
    title,
    description,
    createdAt,
    metadata,
    sync,
  ];
}
