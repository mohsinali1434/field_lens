import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';
import 'package:field_lens/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late InspectionRepositoryImpl inspectionRepository;
  late ObservationRepositoryImpl observationRepository;
  late SettingsRepositoryImpl settingsRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    inspectionRepository = InspectionRepositoryImpl(database);
    observationRepository = ObservationRepositoryImpl(database);
    settingsRepository = SettingsRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('InspectionRepository', () {
    test('saves and retrieves inspections', () async {
      final now = DateTime.utc(2026, 1, 1, 10);
      final inspection = InspectionEntity(
        id: 'insp-1',
        title: 'Site Walkthrough',
        clientName: 'Acme Corp',
        siteName: 'Warehouse A',
        description: 'Monthly inspection',
        status: InspectionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await inspectionRepository.saveInspection(inspection);
      expect(saveResult.isSuccess, isTrue);

      final listResult = await inspectionRepository.getInspections();
      expect(listResult.isSuccess, isTrue);
      expect(listResult.valueOrNull, hasLength(1));
      expect(listResult.valueOrNull!.first.title, 'Site Walkthrough');
    });

    test('soft deletes inspections', () async {
      final now = DateTime.utc(2026, 1, 1, 10);
      final inspection = InspectionEntity(
        id: 'insp-2',
        title: 'To Delete',
        clientName: 'Client',
        siteName: 'Site',
        description: 'Desc',
        status: InspectionStatus.draft,
        createdAt: now,
        updatedAt: now,
      );

      await inspectionRepository.saveInspection(inspection);
      final deleteResult = await inspectionRepository.deleteInspection(
        'insp-2',
      );
      expect(deleteResult.isSuccess, isTrue);

      final listResult = await inspectionRepository.getInspections();
      expect(listResult.valueOrNull, isEmpty);
    });

    test('counts inspections by status', () async {
      final now = DateTime.utc(2026, 1, 1, 10);
      await inspectionRepository.saveInspection(
        InspectionEntity(
          id: 'insp-3',
          title: 'Active',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
          status: InspectionStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await inspectionRepository.saveInspection(
        InspectionEntity(
          id: 'insp-4',
          title: 'Done',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
          status: InspectionStatus.completed,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final active = await inspectionRepository.countActiveInspections();
      final completed = await inspectionRepository.countCompletedInspections();

      expect(active.valueOrNull, 1);
      expect(completed.valueOrNull, 1);
    });
  });

  group('ObservationRepository', () {
    test('saves observations linked to inspections', () async {
      final now = DateTime.utc(2026, 1, 1, 10);
      await inspectionRepository.saveInspection(
        InspectionEntity(
          id: 'insp-obs',
          title: 'Inspection',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
          status: InspectionStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final observation = ObservationEntity(
        id: 'obs-1',
        inspectionId: 'insp-obs',
        title: 'Wall crack',
        description: 'Large crack near eastern wall',
        category: ObservationCategory.structural,
        severity: ObservationSeverity.high,
        status: ObservationStatus.open,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await observationRepository.saveObservation(
        observation,
      );
      expect(saveResult.isSuccess, isTrue);

      final listResult = await observationRepository.getByInspectionId(
        'insp-obs',
      );
      expect(listResult.valueOrNull, hasLength(1));
      expect(listResult.valueOrNull!.first.severity, ObservationSeverity.high);
    });
  });

  group('SettingsRepository', () {
    test('upserts and reads settings', () async {
      final now = DateTime.utc(2026, 1, 1, 10);
      final setting = SettingEntity(
        key: 'inspector_name',
        value: 'Alex Inspector',
        updatedAt: now,
      );

      final saveResult = await settingsRepository.saveSetting(setting);
      expect(saveResult.isSuccess, isTrue);

      final readResult = await settingsRepository.getSetting('inspector_name');
      expect(readResult.valueOrNull?.value, 'Alex Inspector');
    });
  });

  group('Sync metadata', () {
    test('persists sync fields on inspection save', () async {
      final now = DateTime.utc(2026, 1, 1, 10);
      final inspection = InspectionEntity(
        id: 'insp-sync',
        title: 'Sync Test',
        clientName: 'Client',
        siteName: 'Site',
        description: 'Desc',
        status: InspectionStatus.draft,
        createdAt: now,
        updatedAt: now,
        sync: const SyncMetadata(version: 3, remoteId: 'remote-123'),
      );

      await inspectionRepository.saveInspection(inspection);
      final result = await inspectionRepository.getInspectionById('insp-sync');

      expect(result.valueOrNull?.sync.version, 3);
      expect(result.valueOrNull?.sync.remoteId, 'remote-123');
    });
  });
}
