// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observations_dao.dart';

// ignore_for_file: type=lint
mixin _$ObservationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ObservationsTable get observations => attachedDatabase.observations;
  ObservationsDaoManager get managers => ObservationsDaoManager(this);
}

class ObservationsDaoManager {
  final _$ObservationsDaoMixin _db;
  ObservationsDaoManager(this._db);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db.attachedDatabase, _db.observations);
}
