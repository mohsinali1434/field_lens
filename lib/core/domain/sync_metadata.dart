import 'package:equatable/equatable.dart';
import 'package:field_lens/core/domain/sync_status.dart';

/// Shared sync metadata for entities prepared for future REST synchronization.
class SyncMetadata extends Equatable {
  const SyncMetadata({
    this.syncStatus = SyncStatus.localOnly,
    this.remoteId,
    this.lastSyncedAt,
    this.version = 1,
    this.deletedAt,
  });

  final SyncStatus syncStatus;
  final String? remoteId;
  final DateTime? lastSyncedAt;
  final int version;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => <Object?>[
    syncStatus,
    remoteId,
    lastSyncedAt,
    version,
    deletedAt,
  ];
}
