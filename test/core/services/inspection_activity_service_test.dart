import 'dart:io';

import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/services/location_service.dart';
import 'package:field_lens/core/services/media_storage_service.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/timeline_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/media/data/repositories/media_repository_impl.dart';
import 'package:field_lens/core/services/inspection_activity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_path_provider.dart';

class _MockLocationService extends Mock implements LocationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late InspectionActivityService activityService;
  late TimelineRepository timelineRepository;
  late _MockLocationService locationService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('field_lens_activity_test');
    configureFakePathProvider(tempDir.path);
    database = AppDatabase.forTesting(NativeDatabase.memory());

    locationService = _MockLocationService();
    timelineRepository = TimelineRepositoryImpl(database);
    activityService = InspectionActivityService(
      mediaRepository: MediaRepositoryImpl(database),
      timelineRepository: timelineRepository,
      inspectionRepository: InspectionRepositoryImpl(database),
      mediaStorageService: MediaStorageService(),
      locationService: locationService,
    );

    when(() => locationService.getCurrentLocation()).thenAnswer(
      (_) async => const Success<({double latitude, double longitude})>(
        (latitude: 37.77, longitude: -122.42),
      ),
    );
  });

  tearDown(() async {
    await database.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('savePhoto stores media and timeline event', () async {
    final inspectionRepository = InspectionRepositoryImpl(database);
    final now = DateTime.utc(2026, 1, 1);
    await inspectionRepository.saveInspection(
      InspectionEntity(
        id: 'insp-1',
        title: 'Photo Test',
        clientName: 'Client',
        siteName: 'Site',
        description: 'Desc',
        status: InspectionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final source = File('${tempDir.path}/photo.jpg');
    await source.writeAsBytes(<int>[1, 2, 3]);

    final result = await activityService.savePhoto(
      inspectionId: 'insp-1',
      sourcePath: source.path,
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.type.value, 'image');

    final timeline = await timelineRepository.getByInspectionId('insp-1');
    expect(timeline.valueOrNull, hasLength(1));
    expect(
      timeline.valueOrNull!.first.eventType,
      TimelineEventType.photoCaptured,
    );
  });

  test('saveAudio stores media and timeline event', () async {
    final inspectionRepository = InspectionRepositoryImpl(database);
    final now = DateTime.utc(2026, 1, 1);
    await inspectionRepository.saveInspection(
      InspectionEntity(
        id: 'insp-2',
        title: 'Audio Test',
        clientName: 'Client',
        siteName: 'Site',
        description: 'Desc',
        status: InspectionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final source = File('${tempDir.path}/note.m4a');
    await source.writeAsBytes(<int>[4, 5, 6]);

    final result = await activityService.saveAudio(
      inspectionId: 'insp-2',
      sourcePath: source.path,
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.type.value, 'audio');

    final timeline = await timelineRepository.getByInspectionId('insp-2');
    expect(timeline.valueOrNull, hasLength(1));
    expect(
      timeline.valueOrNull!.first.eventType,
      TimelineEventType.voiceNoteRecorded,
    );
  });

  test('saveNote updates inspection and adds timeline event', () async {
    final inspectionRepository = InspectionRepositoryImpl(database);
    final now = DateTime.utc(2026, 1, 1);
    final inspection = InspectionEntity(
      id: 'insp-note',
      title: 'Note Test',
      clientName: 'Client',
      siteName: 'Site',
      description: 'Desc',
      status: InspectionStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
    await inspectionRepository.saveInspection(inspection);

    final result = await activityService.saveNote(
      inspection: inspection,
      note: 'Updated notes',
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.notes, 'Updated notes');

    final timeline = await timelineRepository.getByInspectionId('insp-note');
    expect(timeline.valueOrNull, hasLength(1));
    expect(timeline.valueOrNull!.first.eventType, TimelineEventType.noteAdded);
  });

  test('updateLocation persists coordinates', () async {
    final inspectionRepository = InspectionRepositoryImpl(database);
    final now = DateTime.utc(2026, 1, 1);
    final inspection = InspectionEntity(
      id: 'insp-loc',
      title: 'Location Test',
      clientName: 'Client',
      siteName: 'Site',
      description: 'Desc',
      status: InspectionStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
    await inspectionRepository.saveInspection(inspection);

    final result = await activityService.updateLocation(
      inspection: inspection,
      latitude: 40.71,
      longitude: -74.0,
      address: 'NYC',
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.latitude, 40.71);
    expect(result.valueOrNull?.longitude, -74.0);
    expect(result.valueOrNull?.address, 'NYC');
  });
}
