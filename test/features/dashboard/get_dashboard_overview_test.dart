import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/dashboard/domain/usecases/get_dashboard_overview.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';
import 'package:field_lens/features/reports/data/repositories/report_repository_impl.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late GetDashboardOverviewUseCase useCase;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    useCase = GetDashboardOverviewUseCase(
      inspectionRepository: InspectionRepositoryImpl(database),
      observationRepository: ObservationRepositoryImpl(database),
      reportRepository: ReportRepositoryImpl(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('returns overview with counts and recent inspections', () async {
    final now = DateTime.utc(2026, 1, 1);
    final inspectionRepository = InspectionRepositoryImpl(database);
    final observationRepository = ObservationRepositoryImpl(database);
    final reportRepository = ReportRepositoryImpl(database);

    await inspectionRepository.saveInspection(
      InspectionEntity(
        id: 'active-1',
        title: 'Active Inspection',
        clientName: 'Client',
        siteName: 'Site A',
        description: 'Desc',
        status: InspectionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await inspectionRepository.saveInspection(
      InspectionEntity(
        id: 'done-1',
        title: 'Completed Inspection',
        clientName: 'Client',
        siteName: 'Site B',
        description: 'Desc',
        status: InspectionStatus.completed,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await observationRepository.saveObservation(
      ObservationEntity(
        id: 'obs-1',
        inspectionId: 'active-1',
        title: 'Issue',
        description: 'Problem found',
        category: ObservationCategory.safety,
        severity: ObservationSeverity.high,
        status: ObservationStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await reportRepository.saveReport(
      ReportEntity(
        id: 'report-1',
        inspectionId: 'active-1',
        status: ReportStatus.draft,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.activeInspections, 1);
    expect(result.valueOrNull?.completedInspections, 1);
    expect(result.valueOrNull?.pendingReports, 1);
    expect(result.valueOrNull?.recentInspections, hasLength(2));
    expect(
      result.valueOrNull?.recentInspections.first.observationCount,
      1,
    );
  });
}
