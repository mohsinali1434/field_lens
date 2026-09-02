import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/mappers/sync_mapper.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';

/// Maps between [Observation] rows and [ObservationEntity].
abstract final class ObservationMapper {
  static ObservationEntity toEntity(Observation row) {
    return ObservationEntity(
      id: row.id,
      inspectionId: row.inspectionId,
      title: row.title,
      description: row.description,
      category: ObservationCategory.fromValue(row.category),
      severity: ObservationSeverity.fromValue(row.severity),
      status: ObservationStatus.fromValue(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      latitude: row.latitude,
      longitude: row.longitude,
      dueDate: row.dueDate,
      assignedTo: row.assignedTo,
      sync: SyncMapper.fromRow(
        syncStatus: row.syncStatus,
        remoteId: row.remoteId,
        lastSyncedAt: row.lastSyncedAt,
        version: row.version,
        deletedAt: row.deletedAt,
      ),
    );
  }

  static ObservationsCompanion toCompanion(ObservationEntity entity) {
    return ObservationsCompanion(
      id: Value<String>(entity.id),
      inspectionId: Value<String>(entity.inspectionId),
      title: Value<String>(entity.title),
      description: Value<String>(entity.description),
      category: Value<String>(entity.category.value),
      severity: Value<String>(entity.severity.value),
      status: Value<String>(entity.status.value),
      createdAt: Value<DateTime>(entity.createdAt),
      updatedAt: Value<DateTime>(entity.updatedAt),
      latitude: Value<double?>(entity.latitude),
      longitude: Value<double?>(entity.longitude),
      dueDate: Value<DateTime?>(entity.dueDate),
      assignedTo: Value<String?>(entity.assignedTo),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }
}
