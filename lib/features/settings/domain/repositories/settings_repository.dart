import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';

/// Contract for local settings persistence.
abstract class SettingsRepository {
  Future<Result<SettingEntity?>> getSetting(String key);

  Future<Result<List<SettingEntity>>> getAllSettings();

  Future<Result<SettingEntity>> saveSetting(SettingEntity setting);

  Future<Result<void>> deleteSetting(String key);
}
