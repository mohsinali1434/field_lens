import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/mappers/sync_mapper.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';

/// Maps between [Report] rows and [ReportEntity].
abstract final class ReportMapper {
  static ReportEntity toEntity(Report row) {
    return ReportEntity(
      id: row.id,
      inspectionId: row.inspectionId,
      status: ReportStatus.fromValue(row.status),
      filePath: row.filePath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      generatedAt: row.generatedAt,
      sync: SyncMapper.fromRow(
        syncStatus: row.syncStatus,
        remoteId: row.remoteId,
        lastSyncedAt: row.lastSyncedAt,
        version: row.version,
        deletedAt: row.deletedAt,
      ),
    );
  }

  static ReportsCompanion toCompanion(ReportEntity entity) {
    return ReportsCompanion(
      id: Value<String>(entity.id),
      inspectionId: Value<String>(entity.inspectionId),
      status: Value<String>(entity.status.value),
      filePath: Value<String?>(entity.filePath),
      createdAt: Value<DateTime>(entity.createdAt),
      updatedAt: Value<DateTime>(entity.updatedAt),
      generatedAt: Value<DateTime?>(entity.generatedAt),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }
}
