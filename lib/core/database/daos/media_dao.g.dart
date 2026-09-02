// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dao.dart';

// ignore_for_file: type=lint
mixin _$MediaDaoMixin on DatabaseAccessor<AppDatabase> {
  $MediaRecordsTable get mediaRecords => attachedDatabase.mediaRecords;
  MediaDaoManager get managers => MediaDaoManager(this);
}

class MediaDaoManager {
  final _$MediaDaoMixin _db;
  MediaDaoManager(this._db);
  $$MediaRecordsTableTableManager get mediaRecords =>
      $$MediaRecordsTableTableManager(_db.attachedDatabase, _db.mediaRecords);
}
