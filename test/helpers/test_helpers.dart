import 'package:drift/native.dart';
import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/core/constants/setting_keys.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';

/// Creates an in-memory Drift database for tests.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Configures GetIt with an in-memory database and onboarding complete.
Future<void> configureTestDependencies() async {
  await sl.reset();
  sl.registerLazySingleton<AppDatabase>(createTestDatabase);
  await configureDependencies();
  await sl<SettingsRepository>().saveSetting(
    SettingEntity(
      key: SettingKeys.onboardingComplete,
      value: 'true',
      updatedAt: DateTime.now().toUtc(),
    ),
  );
}
