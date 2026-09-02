/// Future sync states for offline-first data.
enum SyncStatus {
  localOnly('local_only'),
  pendingUpload('pending_upload'),
  synced('synced'),
  pendingUpdate('pending_update'),
  pendingDelete('pending_delete'),
  conflict('conflict');

  const SyncStatus(this.value);

  final String value;

  static SyncStatus fromValue(String value) => SyncStatus.values.firstWhere(
    (SyncStatus status) => status.value == value,
    orElse: () => SyncStatus.localOnly,
  );
}
