import 'package:drift/drift.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/database/tables/media_table.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: <Type>[MediaRecords])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Future<List<MediaRecord>> getByInspectionId(String inspectionId) {
    return (select(mediaRecords)
          ..where((MediaRecords tbl) => tbl.inspectionId.equals(inspectionId))
          ..where((MediaRecords tbl) => tbl.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<MediaRecords>>[
            (MediaRecords tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .get();
  }

  Future<int> insertRecord(MediaRecordsCompanion record) {
    return into(mediaRecords).insert(record, mode: InsertMode.insertOrReplace);
  }
}
