import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/tables/checklist_tables.dart';

part 'checklists_dao.g.dart';

@DriftAccessor(
  tables: <Type>[ChecklistTemplates, ChecklistItems, ChecklistResults],
)
class ChecklistsDao extends DatabaseAccessor<AppDatabase>
    with _$ChecklistsDaoMixin {
  ChecklistsDao(super.db);

  Future<List<ChecklistTemplate>> getAllTemplates() {
    return (select(checklistTemplates)
          ..where((ChecklistTemplates tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<ChecklistTemplates>>[
            (ChecklistTemplates tbl) => OrderingTerm.asc(tbl.name),
          ]))
        .get();
  }

  Future<List<ChecklistItem>> getItemsByTemplateId(String templateId) {
    return (select(checklistItems)
          ..where((ChecklistItems tbl) => tbl.templateId.equals(templateId))
          ..where((ChecklistItems tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<ChecklistItems>>[
            (ChecklistItems tbl) => OrderingTerm.asc(tbl.sortOrder),
          ]))
        .get();
  }

  Future<List<ChecklistResult>> getResultsByInspectionId(String inspectionId) {
    return (select(checklistResults)
          ..where(
            (ChecklistResults tbl) => tbl.inspectionId.equals(inspectionId),
          )
          ..where((ChecklistResults tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<ChecklistResults>>[
            (ChecklistResults tbl) => OrderingTerm.asc(tbl.sortOrder),
          ]))
        .get();
  }

  Future<int> insertTemplate(ChecklistTemplatesCompanion record) {
    return into(checklistTemplates)
        .insert(record, mode: InsertMode.insertOrReplace);
  }

  Future<int> insertItem(ChecklistItemsCompanion record) {
    return into(checklistItems)
        .insert(record, mode: InsertMode.insertOrReplace);
  }

  Future<int> insertResult(ChecklistResultsCompanion record) {
    return into(checklistResults)
        .insert(record, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateResult(ChecklistResultsCompanion record) {
    return update(checklistResults).replace(record);
  }
}
