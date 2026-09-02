import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';

/// Maps between [Setting] rows and [SettingEntity].
abstract final class SettingMapper {
  static SettingEntity toEntity(Setting row) {
    return SettingEntity(
      key: row.key,
      value: row.value,
      updatedAt: row.updatedAt,
    );
  }
}
