import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/settings/data/models/setting_mapper.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';

/// Drift-backed implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Result<SettingEntity?>> getSetting(String key) async {
    try {
      final row = await _database.settingsDao.getByKey(key);
      if (row == null) {
        return const Success<SettingEntity?>(null);
      }
      return Success<SettingEntity?>(SettingMapper.toEntity(row));
    } on Object catch (error) {
      return Error<SettingEntity?>(
        DatabaseFailure(message: 'Failed to load setting: $error'),
      );
    }
  }

  @override
  Future<Result<List<SettingEntity>>> getAllSettings() async {
    try {
      final rows = await _database.settingsDao.getAll();
      return Success<List<SettingEntity>>(
        rows.map(SettingMapper.toEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<SettingEntity>>(
        DatabaseFailure(message: 'Failed to load settings: $error'),
      );
    }
  }

  @override
  Future<Result<SettingEntity>> saveSetting(SettingEntity setting) async {
    try {
      await _database.settingsDao.upsert(
        Setting(
          key: setting.key,
          value: setting.value,
          updatedAt: setting.updatedAt,
        ),
      );
      return Success<SettingEntity>(setting);
    } on Object catch (error) {
      return Error<SettingEntity>(
        DatabaseFailure(message: 'Failed to save setting: $error'),
      );
    }
  }

  @override
  Future<Result<void>> deleteSetting(String key) async {
    try {
      await _database.settingsDao.deleteByKey(key);
      return const Success<void>(null);
    } on Object catch (error) {
      return Error<void>(
        DatabaseFailure(message: 'Failed to delete setting: $error'),
      );
    }
  }
}
