import 'package:drift/drift.dart';

/// Shared sync columns for offline-first entities.
mixin SyncColumns on Table {
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('local_only'))();

  TextColumn get remoteId => text().named('remote_id').nullable()();

  DateTimeColumn get lastSyncedAt =>
      dateTime().named('last_synced_at').nullable()();

  IntColumn get version => integer().withDefault(const Constant(1))();

  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
}
