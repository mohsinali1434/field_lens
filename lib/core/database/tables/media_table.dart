import 'package:drift/drift.dart';
import 'package:field_lens/core/database/tables/sync_columns.dart';

class MediaRecords extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get inspectionId => text().named('inspection_id')();
  TextColumn get observationId => text().named('observation_id').nullable()();
  TextColumn get type => text()();
  TextColumn get filePath => text().named('file_path')();
  TextColumn get thumbnailPath => text().named('thumbnail_path').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE',
    'FOREIGN KEY (observation_id) REFERENCES observations(id) ON DELETE SET NULL',
  ];
}
