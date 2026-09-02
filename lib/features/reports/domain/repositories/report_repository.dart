import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';

/// Contract for report persistence operations.
abstract class ReportRepository {
  Future<Result<List<ReportEntity>>> getByInspectionId(String inspectionId);

  Future<Result<ReportEntity>> saveReport(ReportEntity report);

  Future<Result<int>> countPendingReports();
}
