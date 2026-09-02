import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/mappers/sync_mapper.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_item_status.dart';

/// Maps checklist-related database rows to domain entities.
abstract final class ChecklistMapper {
  static ChecklistTemplateEntity templateToEntity(ChecklistTemplate row) {
    return ChecklistTemplateEntity(
      id: row.id,
      name: row.name,
      description: row.description,
      category: row.category,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      sync: SyncMapper.fromRow(
        syncStatus: row.syncStatus,
        remoteId: row.remoteId,
        lastSyncedAt: row.lastSyncedAt,
        version: row.version,
        deletedAt: row.deletedAt,
      ),
    );
  }

  static ChecklistTemplateItemEntity itemToEntity(ChecklistItem row) {
    return ChecklistTemplateItemEntity(
      id: row.id,
      templateId: row.templateId,
      title: row.title,
      description: row.description,
      required: row.required,
      sortOrder: row.sortOrder,
      sync: SyncMapper.fromRow(
        syncStatus: row.syncStatus,
        remoteId: row.remoteId,
        lastSyncedAt: row.lastSyncedAt,
        version: row.version,
        deletedAt: row.deletedAt,
      ),
    );
  }

  static ChecklistResultEntity resultToEntity(ChecklistResult row) {
    return ChecklistResultEntity(
      id: row.id,
      inspectionId: row.inspectionId,
      templateId: row.templateId,
      itemId: row.itemId,
      title: row.title,
      description: row.description,
      required: row.required,
      status: ChecklistItemStatus.fromValue(row.status),
      notes: row.notes,
      completedAt: row.completedAt,
      sortOrder: row.sortOrder,
      sync: SyncMapper.fromRow(
        syncStatus: row.syncStatus,
        remoteId: row.remoteId,
        lastSyncedAt: row.lastSyncedAt,
        version: row.version,
        deletedAt: row.deletedAt,
      ),
    );
  }

  static ChecklistTemplatesCompanion templateToCompanion(
    ChecklistTemplateEntity entity,
  ) {
    return ChecklistTemplatesCompanion(
      id: Value<String>(entity.id),
      name: Value<String>(entity.name),
      description: Value<String>(entity.description),
      category: Value<String>(entity.category),
      createdAt: Value<DateTime>(entity.createdAt),
      updatedAt: Value<DateTime>(entity.updatedAt),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }

  static ChecklistItemsCompanion itemToCompanion(
    ChecklistTemplateItemEntity entity,
  ) {
    return ChecklistItemsCompanion(
      id: Value<String>(entity.id),
      templateId: Value<String>(entity.templateId),
      title: Value<String>(entity.title),
      description: Value<String>(entity.description),
      required: Value<bool>(entity.required),
      sortOrder: Value<int>(entity.sortOrder),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }

  static ChecklistResultsCompanion resultToCompanion(
    ChecklistResultEntity entity,
  ) {
    return ChecklistResultsCompanion(
      id: Value<String>(entity.id),
      inspectionId: Value<String>(entity.inspectionId),
      templateId: Value<String>(entity.templateId),
      itemId: Value<String>(entity.itemId),
      title: Value<String>(entity.title),
      description: Value<String>(entity.description),
      required: Value<bool>(entity.required),
      status: Value<String>(entity.status.value),
      notes: Value<String?>(entity.notes),
      completedAt: Value<DateTime?>(entity.completedAt),
      sortOrder: Value<int>(entity.sortOrder),
      syncStatus: Value<String>(entity.sync.syncStatus.value),
      remoteId: Value<String?>(entity.sync.remoteId),
      lastSyncedAt: Value<DateTime?>(entity.sync.lastSyncedAt),
      version: Value<int>(entity.sync.version),
      deletedAt: Value<DateTime?>(entity.sync.deletedAt),
    );
  }
}
