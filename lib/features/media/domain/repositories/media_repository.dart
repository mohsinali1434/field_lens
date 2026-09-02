import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';

abstract class MediaRepository {
  Future<Result<List<MediaEntity>>> getByInspectionId(String inspectionId);

  Future<Result<MediaEntity>> save(MediaEntity media);

  Future<Result<void>> delete(String id);
}
