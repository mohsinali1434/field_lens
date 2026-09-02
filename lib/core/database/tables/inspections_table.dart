import 'package:drift/drift.dart';
import 'package:field_lens/core/database/tables/sync_columns.dart';

class Inspections extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get clientName => text().named('client_name')();
  TextColumn get siteName => text().named('site_name')();
  TextColumn get description => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get startedAt => dateTime().named('started_at').nullable()();
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get weatherSummary =>
      text().named('weather_summary').nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get templateId => text().named('template_id').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
