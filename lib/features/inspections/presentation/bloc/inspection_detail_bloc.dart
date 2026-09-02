import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/models/inspection_workspace.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_state.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/media/domain/repositories/media_repository.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class InspectionDetailBloc
    extends Bloc<InspectionDetailEvent, InspectionDetailState> {
  InspectionDetailBloc({
    required InspectionRepository inspectionRepository,
    required ObservationRepository observationRepository,
    required MediaRepository mediaRepository,
    required ChecklistRepository checklistRepository,
    required TimelineRepository timelineRepository,
    required ReportRepository reportRepository,
  }) : _inspectionRepository = inspectionRepository,
       _observationRepository = observationRepository,
       _mediaRepository = mediaRepository,
       _checklistRepository = checklistRepository,
       _timelineRepository = timelineRepository,
       _reportRepository = reportRepository,
       _uuid = const Uuid(),
       super(const InspectionDetailInitial()) {
    on<InspectionDetailStarted>(_onStarted);
    on<InspectionDetailRefreshed>(_onRefreshed);
    on<InspectionStatusChanged>(_onStatusChanged);
    on<InspectionArchived>(_onArchived);
  }

  final InspectionRepository _inspectionRepository;
  final ObservationRepository _observationRepository;
  final MediaRepository _mediaRepository;
  final ChecklistRepository _checklistRepository;
  final TimelineRepository _timelineRepository;
  final ReportRepository _reportRepository;
  final Uuid _uuid;
  String? _inspectionId;

  Future<void> _onStarted(
    InspectionDetailStarted event,
    Emitter<InspectionDetailState> emit,
  ) async {
    _inspectionId = event.inspectionId;
    await _load(emit);
  }

  Future<void> _onRefreshed(
    InspectionDetailRefreshed event,
    Emitter<InspectionDetailState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onStatusChanged(
    InspectionStatusChanged event,
    Emitter<InspectionDetailState> emit,
  ) async {
    final current = state;
    if (current is! InspectionDetailLoaded) return;

    final status = InspectionStatus.fromValue(event.statusValue);
    final updated = current.workspace.inspection.copyWith(
      status: status,
      updatedAt: DateTime.now().toUtc(),
      startedAt: status == InspectionStatus.inProgress
          ? DateTime.now().toUtc()
          : current.workspace.inspection.startedAt,
      completedAt: status == InspectionStatus.completed
          ? DateTime.now().toUtc()
          : current.workspace.inspection.completedAt,
    );
    await _inspectionRepository.saveInspection(updated);
    await _timelineRepository.add(
      TimelineEventEntity(
        id: _uuid.v4(),
        inspectionId: current.workspace.inspection.id,
        eventType: _timelineTypeForStatus(status),
        title: 'Status updated',
        description: 'Inspection marked as ${_statusLabel(status)}.',
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await _load(emit);
  }

  TimelineEventType _timelineTypeForStatus(InspectionStatus status) {
    return switch (status) {
      InspectionStatus.inProgress => TimelineEventType.inspectionStarted,
      InspectionStatus.completed => TimelineEventType.inspectionCompleted,
      _ => TimelineEventType.other,
    };
  }

  String _statusLabel(InspectionStatus status) {
    return switch (status) {
      InspectionStatus.draft => 'Draft',
      InspectionStatus.inProgress => 'In Progress',
      InspectionStatus.completed => 'Completed',
      InspectionStatus.archived => 'Archived',
    };
  }

  Future<void> _onArchived(
    InspectionArchived event,
    Emitter<InspectionDetailState> emit,
  ) async {
    if (_inspectionId == null) return;
    await _inspectionRepository.deleteInspection(_inspectionId!);
    emit(const InspectionDetailFailure('Inspection archived'));
  }

  Future<void> _load(Emitter<InspectionDetailState> emit) async {
    if (_inspectionId == null) return;
    emit(const InspectionDetailLoading());

    final inspectionResult = await _inspectionRepository.getInspectionById(
      _inspectionId!,
    );
    if (inspectionResult.isFailure) {
      emit(InspectionDetailFailure(inspectionResult.failureOrNull!.message));
      return;
    }

    final observations =
        (await _observationRepository.getByInspectionId(_inspectionId!))
            .valueOrNull ??
        <ObservationEntity>[];
    final media =
        (await _mediaRepository.getByInspectionId(_inspectionId!)).valueOrNull ??
        <MediaEntity>[];
    final checklist =
        (await _checklistRepository.getResultsByInspectionId(_inspectionId!))
            .valueOrNull ??
        <ChecklistResultEntity>[];
    final timeline =
        (await _timelineRepository.getByInspectionId(_inspectionId!))
            .valueOrNull ??
        <TimelineEventEntity>[];
    final reports =
        (await _reportRepository.getByInspectionId(_inspectionId!)).valueOrNull ??
        <ReportEntity>[];

    emit(
      InspectionDetailLoaded(
        InspectionWorkspace(
          inspection: inspectionResult.valueOrNull!,
          observations: List.from(observations),
          media: List.from(media),
          checklistResults: List.from(checklist),
          timeline: List.from(timeline),
          reports: List.from(reports),
        ),
      ),
    );
  }
}
