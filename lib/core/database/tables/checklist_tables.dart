import 'package:drift/drift.dart';
import 'package:field_lens/core/database/tables/sync_columns.dart';

class ChecklistTemplates extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class ChecklistItems extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get templateId => text().named('template_id')();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get required => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().named('sort_order')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'FOREIGN KEY (template_id) REFERENCES checklist_templates(id) ON DELETE CASCADE',
  ];
}

class ChecklistResults extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get inspectionId => text().named('inspection_id')();
  TextColumn get templateId => text().named('template_id')();
  TextColumn get itemId => text().named('item_id')();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get required => boolean().withDefault(const Constant(true))();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();
  IntColumn get sortOrder => integer().named('sort_order')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE',
    'FOREIGN KEY (template_id) REFERENCES checklist_templates(id)',
    'FOREIGN KEY (item_id) REFERENCES checklist_items(id)',
  ];
}
