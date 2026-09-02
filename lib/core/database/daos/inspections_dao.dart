import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/tables/inspections_table.dart';

part 'inspections_dao.g.dart';

@DriftAccessor(tables: <Type>[Inspections])
class InspectionsDao extends DatabaseAccessor<AppDatabase>
    with _$InspectionsDaoMixin {
  InspectionsDao(super.db);

  Future<List<Inspection>> getAllActive() {
    return (select(inspections)
          ..where((Inspections tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<Inspections>>[
            (Inspections tbl) => OrderingTerm.desc(tbl.updatedAt),
          ]))
        .get();
  }

  Future<Inspection?> getById(String id) {
    return (select(
      inspections,
    )..where((Inspections tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertRecord(InspectionsCompanion record) {
    return into(inspections).insert(record, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateRecord(InspectionsCompanion record) {
    return update(inspections).replace(record);
  }

  Future<int> softDelete(String id, DateTime deletedAt) {
    return (update(inspections)..where((Inspections tbl) => tbl.id.equals(id)))
        .write(InspectionsCompanion(deletedAt: Value<DateTime>(deletedAt)));
  }

  Future<int> countByStatus(String status) {
    final Expression<int> count = inspections.id.count();
    final query = selectOnly(inspections)
      ..addColumns(<Expression<int>>[count])
      ..where(inspections.status.equals(status))
      ..where(inspections.deletedAt.isNull());
    return query.map((TypedResult row) => row.read(count)!).getSingle();
  }
}
