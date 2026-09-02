import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/core/services/audio_player_service.dart';
import 'package:field_lens/core/services/audio_recorder_service.dart';
import 'package:field_lens/core/services/backup_service.dart';
import 'package:field_lens/core/services/checklist_setup_service.dart';
import 'package:field_lens/core/services/inspection_activity_service.dart';
import 'package:field_lens/core/services/location_service.dart';
import 'package:field_lens/core/services/media_storage_service.dart';
import 'package:field_lens/core/services/ocr_service.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/media/domain/repositories/media_repository.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';

/// Registers core platform and domain services.
void registerServiceDependencies() {
  if (!sl.isRegistered<MediaStorageService>()) {
    sl.registerLazySingleton<MediaStorageService>(MediaStorageService.new);
  }
  if (!sl.isRegistered<LocationService>()) {
    sl.registerLazySingleton<LocationService>(LocationService.new);
  }
  if (!sl.isRegistered<OcrService>()) {
    sl.registerLazySingleton<OcrService>(MlKitOcrService.new);
  }
  if (!sl.isRegistered<AudioRecorderService>()) {
    sl.registerLazySingleton<AudioRecorderService>(AudioRecorderService.new);
  }
  if (!sl.isRegistered<AudioPlayerService>()) {
    sl.registerLazySingleton<AudioPlayerService>(AudioPlayerService.new);
  }
  if (!sl.isRegistered<InspectionActivityService>()) {
    sl.registerLazySingleton<InspectionActivityService>(
      () => InspectionActivityService(
        mediaRepository: sl<MediaRepository>(),
        timelineRepository: sl<TimelineRepository>(),
        inspectionRepository: sl<InspectionRepository>(),
        mediaStorageService: sl<MediaStorageService>(),
        locationService: sl<LocationService>(),
      ),
    );
  }
  if (!sl.isRegistered<ChecklistSetupService>()) {
    sl.registerLazySingleton<ChecklistSetupService>(
      () => ChecklistSetupService(
        checklistRepository: sl<ChecklistRepository>(),
      ),
    );
  }
  if (!sl.isRegistered<BackupService>()) {
    sl.registerLazySingleton<BackupService>(
      () => BackupService(
        inspectionRepository: sl<InspectionRepository>(),
        observationRepository: sl<ObservationRepository>(),
        settingsRepository: sl<SettingsRepository>(),
      ),
    );
  }
}
