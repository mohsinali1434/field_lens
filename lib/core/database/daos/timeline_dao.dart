import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/tables/timeline_events_table.dart';

part 'timeline_dao.g.dart';

@DriftAccessor(tables: <Type>[TimelineEvents])
class TimelineDao extends DatabaseAccessor<AppDatabase> with _$TimelineDaoMixin {
  TimelineDao(super.db);

  Future<List<TimelineEvent>> getByInspectionId(String inspectionId) {
    return (select(timelineEvents)
          ..where((TimelineEvents tbl) => tbl.inspectionId.equals(inspectionId))
          ..where((TimelineEvents tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<TimelineEvents>>[
            (TimelineEvents tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .get();
  }

  Future<int> insertRecord(TimelineEventsCompanion record) {
    return into(timelineEvents).insert(record, mode: InsertMode.insertOrReplace);
  }
}
