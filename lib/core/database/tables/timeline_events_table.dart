import 'package:drift/drift.dart';
import 'package:field_lens/core/database/tables/sync_columns.dart';

class TimelineEvents extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get inspectionId => text().named('inspection_id')();
  TextColumn get eventType => text().named('event_type')();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE',
  ];
}
