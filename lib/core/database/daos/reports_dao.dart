import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/tables/reports_table.dart';

part 'reports_dao.g.dart';

@DriftAccessor(tables: <Type>[Reports])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(super.db);

  Future<List<Report>> getByInspectionId(String inspectionId) {
    return (select(reports)
          ..where((Reports tbl) => tbl.inspectionId.equals(inspectionId))
          ..where((Reports tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<Reports>>[
            (Reports tbl) => OrderingTerm.desc(tbl.updatedAt),
          ]))
        .get();
  }

  Future<int> insertRecord(ReportsCompanion record) {
    return into(reports).insert(record, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateRecord(ReportsCompanion record) {
    return update(reports).replace(record);
  }

  Future<int> countPending() {
    final Expression<int> count = reports.id.count();
    final query = selectOnly(reports)
      ..addColumns(<Expression<int>>[count])
      ..where(reports.status.equals('draft'))
      ..where(reports.deletedAt.isNull());
    return query.map((TypedResult row) => row.read(count)!).getSingle();
  }
}
