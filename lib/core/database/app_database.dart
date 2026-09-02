import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:field_lens/core/database/daos/checklists_dao.dart';
import 'package:field_lens/core/database/daos/inspections_dao.dart';
import 'package:field_lens/core/database/daos/media_dao.dart';
import 'package:field_lens/core/database/daos/observations_dao.dart';
import 'package:field_lens/core/database/daos/reports_dao.dart';
import 'package:field_lens/core/database/daos/settings_dao.dart';
import 'package:field_lens/core/database/daos/timeline_dao.dart';
import 'package:field_lens/core/database/tables/checklist_tables.dart';
import 'package:field_lens/core/database/tables/inspections_table.dart';
import 'package:field_lens/core/database/tables/media_table.dart';
import 'package:field_lens/core/database/tables/observations_table.dart';
import 'package:field_lens/core/database/tables/reports_table.dart';
import 'package:field_lens/core/database/tables/settings_table.dart';
import 'package:field_lens/core/database/tables/timeline_events_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    Inspections,
    Observations,
    MediaRecords,
    ChecklistTemplates,
    ChecklistItems,
    ChecklistResults,
    TimelineEvents,
    Reports,
    Settings,
  ],
  daos: <Type>[
    InspectionsDao,
    ObservationsDao,
    MediaDao,
    ChecklistsDao,
    TimelineDao,
    ReportsDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static AppDatabase create() {
    return AppDatabase(_openConnection());
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'field_lens.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
