import 'package:drift/drift.dart';
import 'package:field_lens/core/database/tables/sync_columns.dart';

class Observations extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get inspectionId => text().named('inspection_id')();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  TextColumn get severity => text()();
  TextColumn get status => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get dueDate => dateTime().named('due_date').nullable()();
  TextColumn get assignedTo => text().named('assigned_to').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE',
  ];
}
