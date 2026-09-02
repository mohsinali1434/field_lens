import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/mappers/sync_mapper.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/media/domain/entities/media_type.dart';

/// Maps between [MediaRecord] rows and [MediaEntity].
abstract final class MediaMapper {
  static MediaEntity toEntity(MediaRecord row) {
    return MediaEntity(
      id: row.id,
      inspectionId: row.inspectionId,
      observationId: row.observationId,
      type: MediaType.fromValue(row.type),
      filePath: row.filePath,
      thumbnailPath: row.thumbnailPath,
      createdAt: row.createdAt,
      latitude: row.latitude,
      longitude: row.longitude,
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

  static MediaRecordsCompanion toCompanion(MediaEntity entity) {
    return MediaRecordsCompanion(
      id: Value<String>(entity.id),
      inspectionId: Value<String>(entity.inspectionId),
      observationId: Value<String?>(entity.observationId),
      type: Value<String>(entity.type.value),
      filePath: Value<String>(entity.filePath),
      thumbnailPath: Value<String?>(entity.thumbnailPath),
      createdAt: Value<DateTime>(entity.createdAt),
      latitude: Value<double?>(entity.latitude),
      longitude: Value<double?>(entity.longitude),
      metadata: Value<String?>(entity.metadata),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }
}
