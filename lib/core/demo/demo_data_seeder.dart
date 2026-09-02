import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_item_status.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';
import 'package:uuid/uuid.dart';

/// Seeds demo inspection data for first-time users.
class DemoDataSeeder {
  const DemoDataSeeder({
    required InspectionRepository inspectionRepository,
    required ObservationRepository observationRepository,
    required ChecklistRepository checklistRepository,
    required ReportRepository reportRepository,
    required SettingsRepository settingsRepository,
    Uuid uuid = const Uuid(),
  }) : _inspectionRepository = inspectionRepository,
       _observationRepository = observationRepository,
       _checklistRepository = checklistRepository,
       _reportRepository = reportRepository,
       _settingsRepository = settingsRepository,
       _uuid = uuid;

  static const String seededKey = 'demo_data_seeded';

  final InspectionRepository _inspectionRepository;
  final ObservationRepository _observationRepository;
  final ChecklistRepository _checklistRepository;
  final ReportRepository _reportRepository;
  final SettingsRepository _settingsRepository;
  final Uuid _uuid;

  Future<Result<void>> seedIfNeeded() async {
    final existing = await _settingsRepository.getSetting(seededKey);
    if (existing.valueOrNull != null) {
      return const Success<void>(null);
    }

    final now = DateTime.now().toUtc();
    final inspectionId = _uuid.v4();
    final templateId = _uuid.v4();

    await _checklistRepository.saveTemplate(
      ChecklistTemplateEntity(
        id: templateId,
        name: 'General Inspection',
        description: 'Standard property walkthrough checklist',
        category: 'General',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final checklistItems = <({String title, ChecklistItemStatus status})>[
      (title: 'Entrance condition', status: ChecklistItemStatus.passed),
      (title: 'Walls', status: ChecklistItemStatus.passed),
      (title: 'Ceiling', status: ChecklistItemStatus.passed),
      (title: 'Flooring', status: ChecklistItemStatus.passed),
      (title: 'Electrical', status: ChecklistItemStatus.failed),
      (title: 'Plumbing', status: ChecklistItemStatus.passed),
      (title: 'Fire safety', status: ChecklistItemStatus.passed),
      (title: 'Emergency exits', status: ChecklistItemStatus.notApplicable),
    ];

    for (var i = 0; i < checklistItems.length; i++) {
      final ({String title, ChecklistItemStatus status}) item =
          checklistItems[i];
      final itemId = _uuid.v4();
      await _checklistRepository.saveTemplateItem(
        ChecklistTemplateItemEntity(
          id: itemId,
          templateId: templateId,
          title: item.title,
          description: 'Inspect ${item.title}',
          required: true,
          sortOrder: i,
        ),
      );
      await _checklistRepository.saveResult(
        ChecklistResultEntity(
          id: _uuid.v4(),
          inspectionId: inspectionId,
          templateId: templateId,
          itemId: itemId,
          title: item.title,
          description: 'Inspect ${item.title}',
          required: true,
          status: item.status,
          sortOrder: i,
          completedAt: now,
        ),
      );
    }

    await _inspectionRepository.saveInspection(
      InspectionEntity(
        id: inspectionId,
        title: 'Residential Property Inspection',
        clientName: 'Demo Client',
        siteName: 'Demo Property',
        description: 'Sample inspection for demonstration purposes.',
        status: InspectionStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        startedAt: now.subtract(const Duration(hours: 3)),
        address: '123 Demo Street, Sample City',
        latitude: 37.7749,
        longitude: -122.4194,
        templateId: templateId,
        notes: 'Demo inspection created automatically.',
      ),
    );

    final observations =
        <
          ({
            String title,
            String description,
            ObservationCategory category,
            ObservationSeverity severity,
          })
        >[
          (
            title: 'Wall crack',
            description: 'Large crack visible near eastern wall.',
            category: ObservationCategory.structural,
            severity: ObservationSeverity.high,
          ),
          (
            title: 'Water leakage',
            description: 'Moisture staining under kitchen sink.',
            category: ObservationCategory.plumbing,
            severity: ObservationSeverity.medium,
          ),
          (
            title: 'Electrical panel issue',
            description: 'Exposed wiring near main electrical panel.',
            category: ObservationCategory.electrical,
            severity: ObservationSeverity.critical,
          ),
        ];

    for (final observation in observations) {
      await _observationRepository.saveObservation(
        ObservationEntity(
          id: _uuid.v4(),
          inspectionId: inspectionId,
          title: observation.title,
          description: observation.description,
          category: observation.category,
          severity: observation.severity,
          status: ObservationStatus.open,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    await _reportRepository.saveReport(
      ReportEntity(
        id: _uuid.v4(),
        inspectionId: inspectionId,
        status: ReportStatus.draft,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _settingsRepository.saveSetting(
      SettingEntity(key: seededKey, value: 'true', updatedAt: now),
    );

    return const Success<void>(null);
  }
}
