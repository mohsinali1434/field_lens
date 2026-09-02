import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';

/// Contract for observation persistence operations.
abstract class ObservationRepository {
  Future<Result<List<ObservationEntity>>> getByInspectionId(
    String inspectionId,
  );

  Future<Result<ObservationEntity>> getById(String id);

  Future<Result<ObservationEntity>> saveObservation(
    ObservationEntity observation,
  );

  Future<Result<int>> countByInspectionId(String inspectionId);
}
