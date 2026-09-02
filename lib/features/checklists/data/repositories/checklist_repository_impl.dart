import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/checklists/data/models/checklist_mapper.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';

/// Drift-backed implementation of [ChecklistRepository].
class ChecklistRepositoryImpl implements ChecklistRepository {
  ChecklistRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Result<List<ChecklistTemplateEntity>>> getTemplates() async {
    try {
      final rows = await _database.checklistsDao.getAllTemplates();
      return Success<List<ChecklistTemplateEntity>>(
        rows.map(ChecklistMapper.templateToEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<ChecklistTemplateEntity>>(
        DatabaseFailure(message: 'Failed to load templates: $error'),
      );
    }
  }

  @override
  Future<Result<List<ChecklistTemplateItemEntity>>> getTemplateItems(
    String templateId,
  ) async {
    try {
      final rows = await _database.checklistsDao.getItemsByTemplateId(
        templateId,
      );
      return Success<List<ChecklistTemplateItemEntity>>(
        rows.map(ChecklistMapper.itemToEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<ChecklistTemplateItemEntity>>(
        DatabaseFailure(message: 'Failed to load template items: $error'),
      );
    }
  }

  @override
  Future<Result<ChecklistTemplateEntity>> saveTemplate(
    ChecklistTemplateEntity template,
  ) async {
    try {
      await _database.checklistsDao.insertTemplate(
        ChecklistMapper.templateToCompanion(template),
      );
      return Success<ChecklistTemplateEntity>(template);
    } on Object catch (error) {
      return Error<ChecklistTemplateEntity>(
        DatabaseFailure(message: 'Failed to save template: $error'),
      );
    }
  }

  @override
  Future<Result<ChecklistTemplateItemEntity>> saveTemplateItem(
    ChecklistTemplateItemEntity item,
  ) async {
    try {
      await _database.checklistsDao.insertItem(
        ChecklistMapper.itemToCompanion(item),
      );
      return Success<ChecklistTemplateItemEntity>(item);
    } on Object catch (error) {
      return Error<ChecklistTemplateItemEntity>(
        DatabaseFailure(message: 'Failed to save template item: $error'),
      );
    }
  }

  @override
  Future<Result<List<ChecklistResultEntity>>> getResultsByInspectionId(
    String inspectionId,
  ) async {
    try {
      final rows = await _database.checklistsDao.getResultsByInspectionId(
        inspectionId,
      );
      return Success<List<ChecklistResultEntity>>(
        rows.map(ChecklistMapper.resultToEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<ChecklistResultEntity>>(
        DatabaseFailure(message: 'Failed to load checklist results: $error'),
      );
    }
  }

  @override
  Future<Result<ChecklistResultEntity>> saveResult(
    ChecklistResultEntity result,
  ) async {
    try {
      await _database.checklistsDao.insertResult(
        ChecklistMapper.resultToCompanion(result),
      );
      return Success<ChecklistResultEntity>(result);
    } on Object catch (error) {
      return Error<ChecklistResultEntity>(
        DatabaseFailure(message: 'Failed to save checklist result: $error'),
      );
    }
  }
}
