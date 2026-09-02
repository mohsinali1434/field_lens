import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';

/// Contract for inspection persistence operations.
abstract class InspectionRepository {
  Future<Result<List<InspectionEntity>>> getInspections();

  Future<Result<InspectionEntity>> getInspectionById(String id);

  Future<Result<InspectionEntity>> saveInspection(InspectionEntity inspection);

  Future<Result<void>> deleteInspection(String id);

  Future<Result<int>> countActiveInspections();

  Future<Result<int>> countCompletedInspections();
}
