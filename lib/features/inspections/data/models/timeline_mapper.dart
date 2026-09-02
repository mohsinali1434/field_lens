import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/mappers/sync_mapper.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';

/// Maps between [TimelineEvent] rows and [TimelineEventEntity].
abstract final class TimelineMapper {
  static TimelineEventEntity toEntity(TimelineEvent row) {
    return TimelineEventEntity(
      id: row.id,
      inspectionId: row.inspectionId,
      eventType: TimelineEventType.fromValue(row.eventType),
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
      metadata: row.metadata,
      sync: SyncMapper.fromRow(
        syncStatus: row.syncStatus,
        remoteId: row.remoteId,
        lastSyncedAt: row.lastSyncedAt,
        version: row.version,
        deletedAt: row.deletedAt,
      ),
    );
  }

  static TimelineEventsCompanion toCompanion(TimelineEventEntity entity) {
    return TimelineEventsCompanion(
      id: Value<String>(entity.id),
      inspectionId: Value<String>(entity.inspectionId),
      eventType: Value<String>(entity.eventType.value),
      title: Value<String>(entity.title),
      description: Value<String>(entity.description),
      createdAt: Value<DateTime>(entity.createdAt),
      metadata: Value<String?>(entity.metadata),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }
}
