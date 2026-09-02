import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/mappers/sync_mapper.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';

/// Maps between [Inspection] rows and [InspectionEntity].
abstract final class InspectionMapper {
  static InspectionEntity toEntity(Inspection row) {
    return InspectionEntity(
      id: row.id,
      title: row.title,
      clientName: row.clientName,
      siteName: row.siteName,
      description: row.description,
      status: InspectionStatus.fromValue(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      latitude: row.latitude,
      longitude: row.longitude,
      address: row.address,
      weatherSummary: row.weatherSummary,
      notes: row.notes,
      templateId: row.templateId,
      sync: SyncMapper.fromRow(
        syncStatus: row.syncStatus,
        remoteId: row.remoteId,
        lastSyncedAt: row.lastSyncedAt,
        version: row.version,
        deletedAt: row.deletedAt,
      ),
    );
  }

  static InspectionsCompanion toCompanion(InspectionEntity entity) {
    return InspectionsCompanion(
      id: Value<String>(entity.id),
      title: Value<String>(entity.title),
      clientName: Value<String>(entity.clientName),
      siteName: Value<String>(entity.siteName),
      description: Value<String>(entity.description),
      status: Value<String>(entity.status.value),
      createdAt: Value<DateTime>(entity.createdAt),
      updatedAt: Value<DateTime>(entity.updatedAt),
      startedAt: Value<DateTime?>(entity.startedAt),
      completedAt: Value<DateTime?>(entity.completedAt),
      latitude: Value<double?>(entity.latitude),
      longitude: Value<double?>(entity.longitude),
      address: Value<String?>(entity.address),
      weatherSummary: Value<String?>(entity.weatherSummary),
      notes: Value<String?>(entity.notes),
      templateId: Value<String?>(entity.templateId),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }
}
