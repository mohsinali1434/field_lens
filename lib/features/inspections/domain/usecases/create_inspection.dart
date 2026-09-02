import 'package:field_lens/core/services/checklist_setup_service.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:uuid/uuid.dart';

/// Input for creating a new draft inspection.
class CreateInspectionInput {
  const CreateInspectionInput({
    required this.title,
    required this.clientName,
    required this.siteName,
    required this.description,
  });

  final String title;
  final String clientName;
  final String siteName;
  final String description;
}

/// Creates and persists a new draft inspection.
class CreateInspectionUseCase {
  CreateInspectionUseCase({
    required InspectionRepository repository,
    required ChecklistSetupService checklistSetupService,
    required TimelineRepository timelineRepository,
    Uuid uuid = const Uuid(),
  }) : _repository = repository,
       _checklistSetupService = checklistSetupService,
       _timelineRepository = timelineRepository,
       _uuid = uuid;

  final InspectionRepository _repository;
  final ChecklistSetupService _checklistSetupService;
  final TimelineRepository _timelineRepository;
  final Uuid _uuid;

  Future<Result<InspectionEntity>> call(CreateInspectionInput input) async {
    final now = DateTime.now().toUtc();
    final inspection = InspectionEntity(
      id: _uuid.v4(),
      title: input.title.trim(),
      clientName: input.clientName.trim(),
      siteName: input.siteName.trim(),
      description: input.description.trim(),
      status: InspectionStatus.draft,
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _repository.saveInspection(inspection);
    if (saved.isFailure) {
      return saved;
    }

    await _checklistSetupService.attachDefaultChecklist(inspection.id);
    await _timelineRepository.add(
      TimelineEventEntity(
        id: _uuid.v4(),
        inspectionId: inspection.id,
        eventType: TimelineEventType.inspectionStarted,
        title: 'Inspection created',
        description: 'A new inspection was created.',
        createdAt: now,
      ),
    );

    return saved;
  }
}
