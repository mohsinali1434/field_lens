import 'package:drift/drift.dart';
import 'package:field_lens/core/database/tables/sync_columns.dart';

class Reports extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get inspectionId => text().named('inspection_id')();
  TextColumn get status => text()();
  TextColumn get filePath => text().named('file_path').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get generatedAt => dateTime().named('generated_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE',
  ];
}
