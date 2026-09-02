import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/services/location_service.dart';
import 'package:field_lens/core/services/media_storage_service.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/media/domain/entities/media_type.dart';
import 'package:field_lens/features/media/domain/repositories/media_repository.dart';
import 'package:uuid/uuid.dart';

/// Coordinates media capture, notes, and timeline events for inspections.
class InspectionActivityService {
  InspectionActivityService({
    required MediaRepository mediaRepository,
    required TimelineRepository timelineRepository,
    required InspectionRepository inspectionRepository,
    required MediaStorageService mediaStorageService,
    required LocationService locationService,
    Uuid uuid = const Uuid(),
  }) : _mediaRepository = mediaRepository,
       _timelineRepository = timelineRepository,
       _inspectionRepository = inspectionRepository,
       _mediaStorageService = mediaStorageService,
       _locationService = locationService,
       _uuid = uuid;

  final MediaRepository _mediaRepository;
  final TimelineRepository _timelineRepository;
  final InspectionRepository _inspectionRepository;
  final MediaStorageService _mediaStorageService;
  final LocationService _locationService;
  final Uuid _uuid;

  Future<Result<MediaEntity>> savePhoto({
    required String inspectionId,
    required String sourcePath,
    String? observationId,
    String? ocrText,
  }) async {
    final stored = await _mediaStorageService.copyToMedia(
      sourcePath: sourcePath,
      extension: 'jpg',
    );
    if (stored.isFailure) {
      return Error<MediaEntity>(stored.failureOrNull!);
    }

    final location = await _locationService.getCurrentLocation();
    final now = DateTime.now().toUtc();
    final media = MediaEntity(
      id: _uuid.v4(),
      inspectionId: inspectionId,
      observationId: observationId,
      type: MediaType.image,
      filePath: stored.valueOrNull!,
      createdAt: now,
      latitude: location.valueOrNull?.latitude,
      longitude: location.valueOrNull?.longitude,
      metadata: ocrText?.trim().isNotEmpty == true ? ocrText!.trim() : null,
    );

    final saved = await _mediaRepository.save(media);
    if (saved.isFailure) {
      return saved;
    }

    await _timelineRepository.add(
      TimelineEventEntity(
        id: _uuid.v4(),
        inspectionId: inspectionId,
        eventType: TimelineEventType.photoCaptured,
        title: 'Photo captured',
        description: 'A photo was added to the inspection.',
        createdAt: now,
      ),
    );

    return saved;
  }

  Future<Result<MediaEntity>> saveAudio({
    required String inspectionId,
    required String sourcePath,
  }) async {
    final stored = await _mediaStorageService.copyToMedia(
      sourcePath: sourcePath,
      extension: 'm4a',
    );
    if (stored.isFailure) {
      return Error<MediaEntity>(stored.failureOrNull!);
    }

    final now = DateTime.now().toUtc();
    final media = MediaEntity(
      id: _uuid.v4(),
      inspectionId: inspectionId,
      type: MediaType.audio,
      filePath: stored.valueOrNull!,
      createdAt: now,
    );

    final saved = await _mediaRepository.save(media);
    if (saved.isFailure) {
      return saved;
    }

    await _timelineRepository.add(
      TimelineEventEntity(
        id: _uuid.v4(),
        inspectionId: inspectionId,
        eventType: TimelineEventType.voiceNoteRecorded,
        title: 'Voice note recorded',
        description: 'A voice note was added to the inspection.',
        createdAt: now,
      ),
    );

    return saved;
  }

  Future<Result<InspectionEntity>> saveNote({
    required InspectionEntity inspection,
    required String note,
  }) async {
    final updated = inspection.copyWith(
      notes: note,
      updatedAt: DateTime.now().toUtc(),
    );
    final result = await _inspectionRepository.saveInspection(updated);
    if (result.isFailure) {
      return result;
    }

    await _timelineRepository.add(
      TimelineEventEntity(
        id: _uuid.v4(),
        inspectionId: inspection.id,
        eventType: TimelineEventType.noteAdded,
        title: 'Note updated',
        description: 'Inspection notes were updated.',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    return result;
  }

  Future<Result<InspectionEntity>> updateLocation({
    required InspectionEntity inspection,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final updated = inspection.copyWith(
      latitude: latitude,
      longitude: longitude,
      address: address ?? inspection.address,
      updatedAt: DateTime.now().toUtc(),
    );
    final result = await _inspectionRepository.saveInspection(updated);
    if (result.isFailure) {
      return result;
    }

    await _timelineRepository.add(
      TimelineEventEntity(
        id: _uuid.v4(),
        inspectionId: inspection.id,
        eventType: TimelineEventType.other,
        title: 'Location updated',
        description: address ?? 'Inspection coordinates were updated.',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    return result;
  }
}
