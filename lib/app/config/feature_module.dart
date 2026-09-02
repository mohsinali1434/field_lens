import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/core/demo/demo_data_seeder.dart';
import 'package:field_lens/core/services/checklist_setup_service.dart';
import 'package:field_lens/core/services/intelligence_service.dart';
import 'package:field_lens/core/services/pdf_report_service.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:field_lens/features/dashboard/domain/usecases/get_dashboard_overview.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/inspections/domain/usecases/create_inspection.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_event.dart';
import 'package:field_lens/features/media/domain/repositories/media_repository.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';
import 'package:field_lens/features/search/domain/usecases/search_data.dart';
import 'package:field_lens/features/search/presentation/bloc/search_bloc.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Provides feature BLoCs to the navigation shell subtree.
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<DashboardBloc>(create: (_) => sl<DashboardBloc>()),
        BlocProvider<InspectionsBloc>(
          create: (_) => sl<InspectionsBloc>()..add(const InspectionsStarted()),
        ),
      ],
      child: child,
    );
  }
}

/// Registers dashboard and inspection feature dependencies.
void registerFeatureDependencies() {
  if (!sl.isRegistered<IntelligenceService>()) {
    sl.registerLazySingleton<IntelligenceService>(
      RuleBasedIntelligenceService.new,
    );
  }

  if (!sl.isRegistered<PdfReportService>()) {
    sl.registerLazySingleton<PdfReportService>(
      () => PdfReportService(
        inspectionRepository: sl<InspectionRepository>(),
        observationRepository: sl<ObservationRepository>(),
        checklistRepository: sl<ChecklistRepository>(),
        reportRepository: sl<ReportRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<GetDashboardOverviewUseCase>()) {
    sl.registerLazySingleton<GetDashboardOverviewUseCase>(
      () => GetDashboardOverviewUseCase(
        inspectionRepository: sl<InspectionRepository>(),
        observationRepository: sl<ObservationRepository>(),
        reportRepository: sl<ReportRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<DemoDataSeeder>()) {
    sl.registerLazySingleton<DemoDataSeeder>(
      () => DemoDataSeeder(
        inspectionRepository: sl<InspectionRepository>(),
        observationRepository: sl<ObservationRepository>(),
        checklistRepository: sl<ChecklistRepository>(),
        reportRepository: sl<ReportRepository>(),
        settingsRepository: sl<SettingsRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<CreateInspectionUseCase>()) {
    sl.registerLazySingleton<CreateInspectionUseCase>(
      () => CreateInspectionUseCase(
        repository: sl<InspectionRepository>(),
        checklistSetupService: sl<ChecklistSetupService>(),
        timelineRepository: sl<TimelineRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchData>()) {
    sl.registerLazySingleton<SearchData>(
      () => SearchData(
        inspectionRepository: sl<InspectionRepository>(),
        observationRepository: sl<ObservationRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<DashboardBloc>()) {
    sl.registerFactory<DashboardBloc>(
      () => DashboardBloc(
        getDashboardOverview: sl<GetDashboardOverviewUseCase>(),
        demoDataSeeder: sl<DemoDataSeeder>(),
      ),
    );
  }

  if (!sl.isRegistered<InspectionsBloc>()) {
    sl.registerFactory<InspectionsBloc>(
      () => InspectionsBloc(repository: sl<InspectionRepository>()),
    );
  }

  if (!sl.isRegistered<CreateInspectionBloc>()) {
    sl.registerFactory<CreateInspectionBloc>(
      () =>
          CreateInspectionBloc(createInspection: sl<CreateInspectionUseCase>()),
    );
  }

  if (!sl.isRegistered<InspectionDetailBloc>()) {
    sl.registerFactory<InspectionDetailBloc>(
      () => InspectionDetailBloc(
        inspectionRepository: sl<InspectionRepository>(),
        observationRepository: sl<ObservationRepository>(),
        mediaRepository: sl<MediaRepository>(),
        checklistRepository: sl<ChecklistRepository>(),
        timelineRepository: sl<TimelineRepository>(),
        reportRepository: sl<ReportRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchBloc>()) {
    sl.registerFactory<SearchBloc>(
      () => SearchBloc(searchData: sl<SearchData>()),
    );
  }
}
