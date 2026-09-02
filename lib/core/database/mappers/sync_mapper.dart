import 'package:drift/drift.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/core/domain/sync_status.dart';

/// Maps sync metadata between domain and database layers.
abstract final class SyncMapper {
  static SyncMetadata fromRow({
    required String syncStatus,
    String? remoteId,
    DateTime? lastSyncedAt,
    required int version,
    DateTime? deletedAt,
  }) {
    return SyncMetadata(
      syncStatus: SyncStatus.fromValue(syncStatus),
      remoteId: remoteId,
      lastSyncedAt: lastSyncedAt,
      version: version,
      deletedAt: deletedAt,
    );
  }

  static void applyToCompanion({
    required SyncMetadata sync,
    required void Function(String syncStatus) setSyncStatus,
    required void Function(Value<String?>) setRemoteId,
    required void Function(Value<DateTime?>) setLastSyncedAt,
    required void Function(int version) setVersion,
    required void Function(Value<DateTime?>) setDeletedAt,
  }) {
    setSyncStatus(sync.syncStatus.value);
    setRemoteId(Value<String?>(sync.remoteId));
    setLastSyncedAt(Value<DateTime?>(sync.lastSyncedAt));
    setVersion(sync.version);
    setDeletedAt(Value<DateTime?>(sync.deletedAt));
  }
}
