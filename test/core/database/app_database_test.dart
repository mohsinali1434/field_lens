import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('database creates all tables on first open', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    final tables = await database.customSelect(
      "SELECT name FROM sqlite_master WHERE type='table'",
    ).get();

    final tableNames = tables
        .map((row) => row.read<String>('name'))
        .toSet();

    expect(tableNames, contains('inspections'));
    expect(tableNames, contains('observations'));
    expect(tableNames, contains('media_records'));
    expect(tableNames, contains('checklist_templates'));
    expect(tableNames, contains('checklist_items'));
    expect(tableNames, contains('checklist_results'));
    expect(tableNames, contains('timeline_events'));
    expect(tableNames, contains('reports'));
    expect(tableNames, contains('settings'));

    await database.close();
  });
}
