import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/dashboard/domain/models/dashboard_overview.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';

/// Loads dashboard statistics and recent inspections.
class GetDashboardOverviewUseCase {
  const GetDashboardOverviewUseCase({
    required InspectionRepository inspectionRepository,
    required ObservationRepository observationRepository,
    required ReportRepository reportRepository,
  }) : _inspectionRepository = inspectionRepository,
       _observationRepository = observationRepository,
       _reportRepository = reportRepository;

  final InspectionRepository _inspectionRepository;
  final ObservationRepository _observationRepository;
  final ReportRepository _reportRepository;

  Future<Result<DashboardOverview>> call() async {
    final activeResult = await _inspectionRepository.countActiveInspections();
    if (activeResult.isFailure) {
      return Error<DashboardOverview>(activeResult.failureOrNull!);
    }

    final completedResult = await _inspectionRepository.countCompletedInspections();
    if (completedResult.isFailure) {
      return Error<DashboardOverview>(completedResult.failureOrNull!);
    }

    final pendingReportsResult = await _reportRepository.countPendingReports();
    if (pendingReportsResult.isFailure) {
      return Error<DashboardOverview>(pendingReportsResult.failureOrNull!);
    }

    final inspectionsResult = await _inspectionRepository.getInspections();
    if (inspectionsResult.isFailure) {
      return Error<DashboardOverview>(inspectionsResult.failureOrNull!);
    }

    final inspections = inspectionsResult.valueOrNull ?? <InspectionEntity>[];
    final recentItems = <RecentInspectionItem>[];

    for (final InspectionEntity inspection in inspections.take(5)) {
      final countResult = await _observationRepository.countByInspectionId(
        inspection.id,
      );
      final observationCount = countResult.valueOrNull ?? 0;

      recentItems.add(
        RecentInspectionItem(
          id: inspection.id,
          title: inspection.title,
          location: inspection.address ?? inspection.siteName,
          date: inspection.updatedAt,
          status: inspection.status,
          observationCount: observationCount,
          completionPercent: _completionPercent(inspection.status),
        ),
      );
    }

    return Success<DashboardOverview>(
      DashboardOverview(
        activeInspections: activeResult.valueOrNull ?? 0,
        completedInspections: completedResult.valueOrNull ?? 0,
        pendingReports: pendingReportsResult.valueOrNull ?? 0,
        recentInspections: recentItems,
      ),
    );
  }

  int _completionPercent(InspectionStatus status) {
    return switch (status) {
      InspectionStatus.draft => 0,
      InspectionStatus.inProgress => 50,
      InspectionStatus.completed => 100,
      InspectionStatus.archived => 100,
    };
  }
}
