import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_item_status.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:uuid/uuid.dart';

/// Attaches and manages checklist items for inspections.
class ChecklistSetupService {
  ChecklistSetupService({
    required ChecklistRepository checklistRepository,
    Uuid uuid = const Uuid(),
  }) : _checklistRepository = checklistRepository,
       _uuid = uuid;

  static const List<String> defaultItems = <String>[
    'Entrance condition',
    'Walls',
    'Ceiling',
    'Flooring',
    'Electrical',
    'Plumbing',
    'Fire safety',
    'Emergency exits',
  ];

  final ChecklistRepository _checklistRepository;
  final Uuid _uuid;

  /// Copies the standard template items onto an inspection.
  Future<Result<int>> attachDefaultChecklist(String inspectionId) async {
    final existing = await _checklistRepository.getResultsByInspectionId(
      inspectionId,
    );
    if (existing.valueOrNull?.isNotEmpty == true) {
      return Success<int>(existing.valueOrNull!.length);
    }

    final templateId = await _getOrCreateDefaultTemplateId();
    if (templateId == null) {
      return const Error<int>(
        DatabaseFailure(message: 'Could not prepare checklist template'),
      );
    }

    final items =
        (await _checklistRepository.getTemplateItems(templateId)).valueOrNull ??
        <ChecklistTemplateItemEntity>[];

    if (items.isEmpty) {
      return const Error<int>(
        DatabaseFailure(message: 'Checklist template has no items'),
      );
    }

    for (final item in items) {
      final saved = await _checklistRepository.saveResult(
        ChecklistResultEntity(
          id: _uuid.v4(),
          inspectionId: inspectionId,
          templateId: templateId,
          itemId: item.id,
          title: item.title,
          description: item.description,
          required: item.required,
          status: ChecklistItemStatus.notStarted,
          sortOrder: item.sortOrder,
        ),
      );
      if (saved.isFailure) {
        return Error<int>(saved.failureOrNull!);
      }
    }

    return Success<int>(items.length);
  }

  /// Adds a custom checklist item to an inspection.
  Future<Result<ChecklistResultEntity>> addCustomItem({
    required String inspectionId,
    required String title,
    String description = '',
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return const Error<ChecklistResultEntity>(
        UnknownFailure(message: 'Checklist item title is required'),
      );
    }

    final templateId = await _getOrCreateDefaultTemplateId();
    if (templateId == null) {
      return const Error<ChecklistResultEntity>(
        DatabaseFailure(message: 'Could not prepare checklist template'),
      );
    }

    final existing = await _checklistRepository.getResultsByInspectionId(
      inspectionId,
    );
    final sortOrder = existing.valueOrNull?.length ?? 0;
    final itemId = _uuid.v4();

    return _checklistRepository.saveResult(
      ChecklistResultEntity(
        id: _uuid.v4(),
        inspectionId: inspectionId,
        templateId: templateId,
        itemId: itemId,
        title: trimmedTitle,
        description: description.trim(),
        required: false,
        status: ChecklistItemStatus.notStarted,
        sortOrder: sortOrder,
      ),
    );
  }

  Future<String?> _getOrCreateDefaultTemplateId() async {
    final templates = (await _checklistRepository.getTemplates()).valueOrNull;
    final now = DateTime.now().toUtc();

    if (templates != null && templates.isNotEmpty) {
      final templateId = templates.first.id;
      final items =
          (await _checklistRepository.getTemplateItems(templateId)).valueOrNull;
      if (items != null && items.isNotEmpty) {
        return templateId;
      }
    }

    final templateId = _uuid.v4();
    final savedTemplate = await _checklistRepository.saveTemplate(
      ChecklistTemplateEntity(
        id: templateId,
        name: 'General Inspection',
        description: 'Standard property walkthrough checklist',
        category: 'General',
        createdAt: now,
        updatedAt: now,
      ),
    );
    if (savedTemplate.isFailure) {
      return null;
    }

    for (var i = 0; i < defaultItems.length; i++) {
      final savedItem = await _checklistRepository.saveTemplateItem(
        ChecklistTemplateItemEntity(
          id: _uuid.v4(),
          templateId: templateId,
          title: defaultItems[i],
          description: 'Inspect ${defaultItems[i]}',
          required: true,
          sortOrder: i,
        ),
      );
      if (savedItem.isFailure) {
        return null;
      }
    }

    return templateId;
  }
}
