import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/observations/data/models/observation_mapper.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';

/// Drift-backed implementation of [ObservationRepository].
class ObservationRepositoryImpl implements ObservationRepository {
  ObservationRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Result<List<ObservationEntity>>> getByInspectionId(
    String inspectionId,
  ) async {
    try {
      final rows = await _database.observationsDao.getByInspectionId(
        inspectionId,
      );
      return Success<List<ObservationEntity>>(
        rows.map(ObservationMapper.toEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<ObservationEntity>>(
        DatabaseFailure(message: 'Failed to load observations: $error'),
      );
    }
  }

  @override
  Future<Result<ObservationEntity>> getById(String id) async {
    try {
      final row = await _database.observationsDao.getById(id);
      if (row == null || row.deletedAt != null) {
        return const Error<ObservationEntity>(
          DatabaseFailure(message: 'Observation not found'),
        );
      }
      return Success<ObservationEntity>(ObservationMapper.toEntity(row));
    } on Object catch (error) {
      return Error<ObservationEntity>(
        DatabaseFailure(message: 'Failed to load observation: $error'),
      );
    }
  }

  @override
  Future<Result<ObservationEntity>> saveObservation(
    ObservationEntity observation,
  ) async {
    try {
      await _database.observationsDao.insertRecord(
        ObservationMapper.toCompanion(observation),
      );
      return Success<ObservationEntity>(observation);
    } on Object catch (error) {
      return Error<ObservationEntity>(
        DatabaseFailure(message: 'Failed to save observation: $error'),
      );
    }
  }

  @override
  Future<Result<int>> countByInspectionId(String inspectionId) async {
    try {
      final count = await _database.observationsDao.countByInspectionId(
        inspectionId,
      );
      return Success<int>(count);
    } on Object catch (error) {
      return Error<int>(
        DatabaseFailure(message: 'Failed to count observations: $error'),
      );
    }
  }
}
