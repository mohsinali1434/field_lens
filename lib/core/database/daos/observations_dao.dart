import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/tables/observations_table.dart';

part 'observations_dao.g.dart';

@DriftAccessor(tables: <Type>[Observations])
class ObservationsDao extends DatabaseAccessor<AppDatabase>
    with _$ObservationsDaoMixin {
  ObservationsDao(super.db);

  Future<List<Observation>> getByInspectionId(String inspectionId) {
    return (select(observations)
          ..where((Observations tbl) => tbl.inspectionId.equals(inspectionId))
          ..where((Observations tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<Observations>>[
            (Observations tbl) => OrderingTerm.desc(tbl.updatedAt),
          ]))
        .get();
  }

  Future<Observation?> getById(String id) {
    return (select(
      observations,
    )..where((Observations tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertRecord(ObservationsCompanion record) {
    return into(observations).insert(record, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateRecord(ObservationsCompanion record) {
    return update(observations).replace(record);
  }

  Future<int> countByInspectionId(String inspectionId) {
    final Expression<int> count = observations.id.count();
    final query = selectOnly(observations)
      ..addColumns(<Expression<int>>[count])
      ..where(observations.inspectionId.equals(inspectionId))
      ..where(observations.deletedAt.isNull());
    return query.map((TypedResult row) => row.read(count)!).getSingle();
  }
}
