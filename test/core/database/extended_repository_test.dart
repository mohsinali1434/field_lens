import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/checklists/data/repositories/checklist_repository_impl.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_item_status.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/timeline_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';
import 'package:field_lens/features/media/data/repositories/media_repository_impl.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/media/domain/entities/media_type.dart';
import 'package:field_lens/features/reports/data/repositories/report_repository_impl.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('MediaRepository', () {
    test('saves and retrieves media by inspection', () async {
      final repository = MediaRepositoryImpl(database);
      final inspectionRepository = InspectionRepositoryImpl(database);
      final now = DateTime.utc(2026, 1, 1);

      await inspectionRepository.saveInspection(
        InspectionEntity(
          id: 'insp-1',
          title: 'Media Test',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
          status: InspectionStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repository.save(
        MediaEntity(
          id: 'media-1',
          inspectionId: 'insp-1',
          type: MediaType.image,
          filePath: '/tmp/photo.jpg',
          createdAt: now,
        ),
      );

      final result = await repository.getByInspectionId('insp-1');
      expect(result.valueOrNull, hasLength(1));
      expect(result.valueOrNull!.first.filePath, '/tmp/photo.jpg');
    });
  });

  group('TimelineRepository', () {
    test('adds and retrieves timeline events', () async {
      final repository = TimelineRepositoryImpl(database);
      final inspectionRepository = InspectionRepositoryImpl(database);
      final now = DateTime.utc(2026, 1, 1);

      await inspectionRepository.saveInspection(
        InspectionEntity(
          id: 'insp-1',
          title: 'Timeline Test',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
          status: InspectionStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repository.add(
        TimelineEventEntity(
          id: 'event-1',
          inspectionId: 'insp-1',
          eventType: TimelineEventType.observationCreated,
          title: 'Observation added',
          description: 'Wall crack documented',
          createdAt: now,
        ),
      );

      final result = await repository.getByInspectionId('insp-1');
      expect(result.valueOrNull, hasLength(1));
      expect(result.valueOrNull!.first.title, 'Observation added');
    });
  });

  group('ChecklistRepository', () {
    test('saves templates, items, and results', () async {
      final repository = ChecklistRepositoryImpl(database);
      final inspectionRepository = InspectionRepositoryImpl(database);
      final now = DateTime.utc(2026, 1, 1);

      await inspectionRepository.saveInspection(
        InspectionEntity(
          id: 'insp-1',
          title: 'Checklist Test',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
          status: InspectionStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repository.saveTemplate(
        ChecklistTemplateEntity(
          id: 'tpl-1',
          name: 'Safety',
          description: 'Safety checklist',
          category: 'Safety',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.saveTemplateItem(
        ChecklistTemplateItemEntity(
          id: 'item-1',
          templateId: 'tpl-1',
          title: 'Fire extinguisher',
          description: 'Check expiry',
          required: true,
          sortOrder: 0,
        ),
      );
      await repository.saveResult(
        ChecklistResultEntity(
          id: 'result-1',
          inspectionId: 'insp-1',
          templateId: 'tpl-1',
          itemId: 'item-1',
          title: 'Fire extinguisher',
          description: 'Check expiry',
          required: true,
          status: ChecklistItemStatus.passed,
          sortOrder: 0,
          completedAt: now,
        ),
      );

      final templates = await repository.getTemplates();
      final items = await repository.getTemplateItems('tpl-1');
      final results = await repository.getResultsByInspectionId('insp-1');

      expect(templates.valueOrNull, hasLength(1));
      expect(items.valueOrNull, hasLength(1));
      expect(results.valueOrNull, hasLength(1));
      expect(results.valueOrNull!.first.status, ChecklistItemStatus.passed);
    });
  });

  group('ReportRepository', () {
    test('saves reports and counts pending', () async {
      final repository = ReportRepositoryImpl(database);
      final inspectionRepository = InspectionRepositoryImpl(database);
      final now = DateTime.utc(2026, 1, 1);

      await inspectionRepository.saveInspection(
        InspectionEntity(
          id: 'insp-report',
          title: 'Report Test',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
          status: InspectionStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await repository.saveReport(
        ReportEntity(
          id: 'report-1',
          inspectionId: 'insp-report',
          status: ReportStatus.draft,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final reports = await repository.getByInspectionId('insp-report');
      final pending = await repository.countPendingReports();

      expect(reports.valueOrNull, hasLength(1));
      expect(pending.valueOrNull, 1);
    });
  });
}
