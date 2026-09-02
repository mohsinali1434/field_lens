import 'package:field_lens/core/sync/sync_manager.dart';

/// Placeholder for future REST synchronization.
abstract class SyncManager {
  Future<void> scheduleUpload(String entityType, String entityId);
}

class LocalSyncManager implements SyncManager {
  @override
  Future<void> scheduleUpload(String entityType, String entityId) async {}
}
