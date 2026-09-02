// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklists_dao.dart';

// ignore_for_file: type=lint
mixin _$ChecklistsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChecklistTemplatesTable get checklistTemplates =>
      attachedDatabase.checklistTemplates;
  $ChecklistItemsTable get checklistItems => attachedDatabase.checklistItems;
  $ChecklistResultsTable get checklistResults =>
      attachedDatabase.checklistResults;
  ChecklistsDaoManager get managers => ChecklistsDaoManager(this);
}

class ChecklistsDaoManager {
  final _$ChecklistsDaoMixin _db;
  ChecklistsDaoManager(this._db);
  $$ChecklistTemplatesTableTableManager get checklistTemplates =>
      $$ChecklistTemplatesTableTableManager(
        _db.attachedDatabase,
        _db.checklistTemplates,
      );
  $$ChecklistItemsTableTableManager get checklistItems =>
      $$ChecklistItemsTableTableManager(
        _db.attachedDatabase,
        _db.checklistItems,
      );
  $$ChecklistResultsTableTableManager get checklistResults =>
      $$ChecklistResultsTableTableManager(
        _db.attachedDatabase,
        _db.checklistResults,
      );
}
