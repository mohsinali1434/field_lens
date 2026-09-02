import 'package:equatable/equatable.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';

/// Aggregated inspection workspace data.
class InspectionWorkspace extends Equatable {
  const InspectionWorkspace({
    required this.inspection,
    required this.observations,
    required this.media,
    required this.checklistResults,
    required this.timeline,
    required this.reports,
  });

  final InspectionEntity inspection;
  final List<ObservationEntity> observations;
  final List<MediaEntity> media;
  final List<ChecklistResultEntity> checklistResults;
  final List<TimelineEventEntity> timeline;
  final List<ReportEntity> reports;

  @override
  List<Object?> get props => <Object?>[
    inspection,
    observations,
    media,
    checklistResults,
    timeline,
    reports,
  ];
}
