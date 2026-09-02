import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/data/models/inspection_mapper.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';

/// Drift-backed implementation of [InspectionRepository].
class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Result<List<InspectionEntity>>> getInspections() async {
    try {
      final rows = await _database.inspectionsDao.getAllActive();
      return Success<List<InspectionEntity>>(
        rows.map(InspectionMapper.toEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<InspectionEntity>>(
        DatabaseFailure(message: 'Failed to load inspections: $error'),
      );
    }
  }

  @override
  Future<Result<InspectionEntity>> getInspectionById(String id) async {
    try {
      final row = await _database.inspectionsDao.getById(id);
      if (row == null || row.deletedAt != null) {
        return const Error<InspectionEntity>(
          DatabaseFailure(message: 'Inspection not found'),
        );
      }
      return Success<InspectionEntity>(InspectionMapper.toEntity(row));
    } on Object catch (error) {
      return Error<InspectionEntity>(
        DatabaseFailure(message: 'Failed to load inspection: $error'),
      );
    }
  }

  @override
  Future<Result<InspectionEntity>> saveInspection(
    InspectionEntity inspection,
  ) async {
    try {
      await _database.inspectionsDao.insertRecord(
        InspectionMapper.toCompanion(inspection),
      );
      return Success<InspectionEntity>(inspection);
    } on Object catch (error) {
      return Error<InspectionEntity>(
        DatabaseFailure(message: 'Failed to save inspection: $error'),
      );
    }
  }

  @override
  Future<Result<void>> deleteInspection(String id) async {
    try {
      await _database.inspectionsDao.softDelete(id, DateTime.now().toUtc());
      return const Success<void>(null);
    } on Object catch (error) {
      return Error<void>(
        DatabaseFailure(message: 'Failed to delete inspection: $error'),
      );
    }
  }

  @override
  Future<Result<int>> countActiveInspections() async {
    try {
      final draftCount = await _database.inspectionsDao.countByStatus(
        InspectionStatus.draft.value,
      );
      final inProgressCount = await _database.inspectionsDao.countByStatus(
        InspectionStatus.inProgress.value,
      );
      return Success<int>(draftCount + inProgressCount);
    } on Object catch (error) {
      return Error<int>(
        DatabaseFailure(message: 'Failed to count inspections: $error'),
      );
    }
  }

  @override
  Future<Result<int>> countCompletedInspections() async {
    try {
      final count = await _database.inspectionsDao.countByStatus(
        InspectionStatus.completed.value,
      );
      return Success<int>(count);
    } on Object catch (error) {
      return Error<int>(
        DatabaseFailure(message: 'Failed to count inspections: $error'),
      );
    }
  }
}
