import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/reports/data/models/report_mapper.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';

/// Drift-backed implementation of [ReportRepository].
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Result<List<ReportEntity>>> getByInspectionId(
    String inspectionId,
  ) async {
    try {
      final rows = await _database.reportsDao.getByInspectionId(inspectionId);
      return Success<List<ReportEntity>>(
        rows.map(ReportMapper.toEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<ReportEntity>>(
        DatabaseFailure(message: 'Failed to load reports: $error'),
      );
    }
  }

  @override
  Future<Result<ReportEntity>> saveReport(ReportEntity report) async {
    try {
      await _database.reportsDao.insertRecord(
        ReportMapper.toCompanion(report),
      );
      return Success<ReportEntity>(report);
    } on Object catch (error) {
      return Error<ReportEntity>(
        DatabaseFailure(message: 'Failed to save report: $error'),
      );
    }
  }

  @override
  Future<Result<int>> countPendingReports() async {
    try {
      final count = await _database.reportsDao.countPending();
      return Success<int>(count);
    } on Object catch (error) {
      return Error<int>(
        DatabaseFailure(message: 'Failed to count reports: $error'),
      );
    }
  }
}
