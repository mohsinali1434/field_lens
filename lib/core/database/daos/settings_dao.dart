import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: <Type>[Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<Setting?> getByKey(String key) {
    return (select(
      settings,
    )..where((Settings tbl) => tbl.key.equals(key))).getSingleOrNull();
  }

  Future<List<Setting>> getAll() => select(settings).get();

  Future<int> upsert(Setting setting) {
    return into(settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: Value<String>(setting.key),
        value: Value<String>(setting.value),
        updatedAt: Value<DateTime>(setting.updatedAt),
      ),
    );
  }

  Future<int> deleteByKey(String key) {
    return (delete(settings)..where((Settings tbl) => tbl.key.equals(key)))
        .go();
  }
}
