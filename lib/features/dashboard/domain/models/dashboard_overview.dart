import 'package:equatable/equatable.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';

/// Summary item for the dashboard recent inspections list.
class RecentInspectionItem extends Equatable {
  const RecentInspectionItem({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.observationCount,
    required this.completionPercent,
  });

  final String id;
  final String title;
  final String location;
  final DateTime date;
  final InspectionStatus status;
  final int observationCount;
  final int completionPercent;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    location,
    date,
    status,
    observationCount,
    completionPercent,
  ];
}

/// Aggregated dashboard statistics and recent activity.
class DashboardOverview extends Equatable {
  const DashboardOverview({
    required this.activeInspections,
    required this.completedInspections,
    required this.pendingReports,
    required this.recentInspections,
  });

  final int activeInspections;
  final int completedInspections;
  final int pendingReports;
  final List<RecentInspectionItem> recentInspections;

  bool get isEmpty => recentInspections.isEmpty;

  @override
  List<Object?> get props => <Object?>[
    activeInspections,
    completedInspections,
    pendingReports,
    recentInspections,
  ];
}
