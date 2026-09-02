import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';

abstract class TimelineRepository {
  Future<Result<List<TimelineEventEntity>>> getByInspectionId(
    String inspectionId,
  );

  Future<Result<TimelineEventEntity>> add(TimelineEventEntity event);
}
