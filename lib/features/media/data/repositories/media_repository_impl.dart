import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/media/data/models/media_mapper.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/media/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Result<List<MediaEntity>>> getByInspectionId(
    String inspectionId,
  ) async {
    try {
      final rows = await _database.mediaDao.getByInspectionId(inspectionId);
      return Success<List<MediaEntity>>(
        rows.map(MediaMapper.toEntity).toList(),
      );
    } on Object catch (error) {
      return Error<List<MediaEntity>>(
        DatabaseFailure(message: 'Failed to load media: $error'),
      );
    }
  }

  @override
  Future<Result<MediaEntity>> save(MediaEntity media) async {
    try {
      await _database.mediaDao.insertRecord(MediaMapper.toCompanion(media));
      return Success<MediaEntity>(media);
    } on Object catch (error) {
      return Error<MediaEntity>(
        DatabaseFailure(message: 'Failed to save media: $error'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    return const Success<void>(null);
  }
}
