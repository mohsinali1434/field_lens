import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';

/// Contract for checklist template and result persistence.
abstract class ChecklistRepository {
  Future<Result<List<ChecklistTemplateEntity>>> getTemplates();

  Future<Result<List<ChecklistTemplateItemEntity>>> getTemplateItems(
    String templateId,
  );

  Future<Result<ChecklistTemplateEntity>> saveTemplate(
    ChecklistTemplateEntity template,
  );

  Future<Result<ChecklistTemplateItemEntity>> saveTemplateItem(
    ChecklistTemplateItemEntity item,
  );

  Future<Result<List<ChecklistResultEntity>>> getResultsByInspectionId(
    String inspectionId,
  );

  Future<Result<ChecklistResultEntity>> saveResult(
    ChecklistResultEntity result,
  );
}
