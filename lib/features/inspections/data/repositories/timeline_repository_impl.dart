import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/data/models/timeline_mapper.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  TimelineRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Result<List<TimelineEventEntity>>> getByInspectionId(
    String inspectionId,
  ) async {
    try {
      final rows = await _database.timelineDao.getByInspectionId(inspectionId);
      return Success<List<TimelineEventEntity>>(
        rows.map(TimelineMapper.toEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<TimelineEventEntity>>(
        DatabaseFailure(message: 'Failed to load timeline: $error'),
      );
    }
  }

  @override
  Future<Result<TimelineEventEntity>> add(TimelineEventEntity event) async {
    try {
      await _database.timelineDao.insertRecord(
        TimelineMapper.toCompanion(event),
      );
      return Success<TimelineEventEntity>(event);
    } on Object catch (error) {
      return Error<TimelineEventEntity>(
        DatabaseFailure(message: 'Failed to save timeline event: $error'),
      );
    }
  }
}
