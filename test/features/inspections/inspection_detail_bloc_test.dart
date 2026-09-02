import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/checklists/data/repositories/checklist_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/timeline_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_state.dart';
import 'package:field_lens/features/media/data/repositories/media_repository_impl.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/reports/data/repositories/report_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

InspectionDetailBloc _createBloc(AppDatabase database) {
  return InspectionDetailBloc(
    inspectionRepository: InspectionRepositoryImpl(database),
    observationRepository: ObservationRepositoryImpl(database),
    mediaRepository: MediaRepositoryImpl(database),
    checklistRepository: ChecklistRepositoryImpl(database),
    timelineRepository: TimelineRepositoryImpl(database),
    reportRepository: ReportRepositoryImpl(database),
  );
}

Future<void> _seedInspection(AppDatabase database) async {
  final now = DateTime.utc(2026, 1, 1);
  await InspectionRepositoryImpl(database).saveInspection(
    InspectionEntity(
      id: 'detail-insp',
      title: 'Detail Inspection',
      clientName: 'Client',
      siteName: 'Site',
      description: 'Detailed walkthrough',
      status: InspectionStatus.inProgress,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await _seedInspection(database);
  });

  tearDown(() async {
    await database.close();
  });

  blocTest<InspectionDetailBloc, InspectionDetailState>(
    'loads inspection workspace',
    build: () => _createBloc(database),
    act: (InspectionDetailBloc bloc) =>
        bloc.add(const InspectionDetailStarted('detail-insp')),
    expect: () => <dynamic>[
      const InspectionDetailLoading(),
      isA<InspectionDetailLoaded>(),
    ],
    verify: (InspectionDetailBloc bloc) {
      final state = bloc.state as InspectionDetailLoaded;
      expect(state.workspace.inspection.title, 'Detail Inspection');
    },
  );

  blocTest<InspectionDetailBloc, InspectionDetailState>(
    'updates inspection status',
    build: () => _createBloc(database),
    act: (InspectionDetailBloc bloc) async {
      bloc.add(const InspectionDetailStarted('detail-insp'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        const InspectionStatusChanged('completed'),
      );
    },
    expect: () => <dynamic>[
      const InspectionDetailLoading(),
      isA<InspectionDetailLoaded>(),
      const InspectionDetailLoading(),
      isA<InspectionDetailLoaded>(),
    ],
    verify: (InspectionDetailBloc bloc) {
      final state = bloc.state as InspectionDetailLoaded;
      expect(state.workspace.inspection.status, InspectionStatus.completed);
      expect(state.workspace.inspection.completedAt, isNotNull);
    },
  );

  blocTest<InspectionDetailBloc, InspectionDetailState>(
    'archives inspection',
    build: () => _createBloc(database),
    act: (InspectionDetailBloc bloc) async {
      bloc.add(const InspectionDetailStarted('detail-insp'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const InspectionArchived());
    },
    expect: () => <dynamic>[
      const InspectionDetailLoading(),
      isA<InspectionDetailLoaded>(),
      const InspectionDetailFailure('Inspection archived'),
    ],
  );
}
