import 'dart:io';

import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/services/backup_service.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late BackupService backupService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('field_lens_backup_test');
    configureFakePathProvider(tempDir.path);
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final inspectionRepository = InspectionRepositoryImpl(database);
    final observationRepository = ObservationRepositoryImpl(database);
    final settingsRepository = SettingsRepositoryImpl(database);
    backupService = BackupService(
      inspectionRepository: inspectionRepository,
      observationRepository: observationRepository,
      settingsRepository: settingsRepository,
    );
  });

  tearDown(() async {
    await database.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('exports backup zip file', () async {
    final now = DateTime.utc(2026, 1, 1);
    await InspectionRepositoryImpl(database).saveInspection(
      InspectionEntity(
        id: 'backup-insp',
        title: 'Backup Test',
        clientName: 'Client',
        siteName: 'Site',
        description: 'Desc',
        status: InspectionStatus.draft,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await SettingsRepositoryImpl(database).saveSetting(
      SettingEntity(key: 'theme', value: 'dark', updatedAt: now),
    );

    final result = await backupService.exportBackup();

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, endsWith('.zip'));
  });
}
