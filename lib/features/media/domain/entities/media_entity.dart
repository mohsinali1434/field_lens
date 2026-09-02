import 'package:equatable/equatable.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/features/media/domain/entities/media_type.dart';

/// Domain representation of a media attachment.
class MediaEntity extends Equatable {
  const MediaEntity({
    required this.id,
    required this.inspectionId,
    required this.type,
    required this.filePath,
    required this.createdAt,
    this.observationId,
    this.thumbnailPath,
    this.latitude,
    this.longitude,
    this.metadata,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String inspectionId;
  final String? observationId;
  final MediaType type;
  final String filePath;
  final String? thumbnailPath;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? metadata;
  final SyncMetadata sync;

  @override
  List<Object?> get props => <Object?>[
    id,
    inspectionId,
    observationId,
    type,
    filePath,
    thumbnailPath,
    createdAt,
    latitude,
    longitude,
    metadata,
    sync,
  ];
}
