import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/checklists/data/repositories/checklist_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/timeline_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/media/data/repositories/media_repository_impl.dart';
import 'package:field_lens/features/media/domain/repositories/media_repository.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/reports/data/repositories/report_repository_impl.dart';
import 'package:field_lens/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';
import 'package:get_it/get_it.dart';

/// Registers database and repository dependencies.
void registerDatabaseDependencies(GetIt getIt) {
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(AppDatabase.create);
  }
  if (!getIt.isRegistered<InspectionRepository>()) {
    getIt.registerLazySingleton<InspectionRepository>(
      () => InspectionRepositoryImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<ObservationRepository>()) {
    getIt.registerLazySingleton<ObservationRepository>(
      () => ObservationRepositoryImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<ChecklistRepository>()) {
    getIt.registerLazySingleton<ChecklistRepository>(
      () => ChecklistRepositoryImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<ReportRepository>()) {
    getIt.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<SettingsRepository>()) {
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<MediaRepository>()) {
    getIt.registerLazySingleton<MediaRepository>(
      () => MediaRepositoryImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<TimelineRepository>()) {
    getIt.registerLazySingleton<TimelineRepository>(
      () => TimelineRepositoryImpl(getIt<AppDatabase>()),
    );
  }
}
