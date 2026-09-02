import 'package:bloc_test/bloc_test.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockInspectionRepository extends Mock implements InspectionRepository {}

void main() {
  late _MockInspectionRepository repository;

  setUp(() {
    repository = _MockInspectionRepository();
  });

  blocTest<InspectionsBloc, InspectionsState>(
    'emits loaded inspections',
    build: () => InspectionsBloc(repository: repository),
    setUp: () {
      when(() => repository.getInspections()).thenAnswer(
        (_) async => Success<List<InspectionEntity>>(<InspectionEntity>[
          InspectionEntity(
            id: '1',
            title: 'Inspection A',
            clientName: 'Client',
            siteName: 'Site',
            description: 'Desc',
            status: InspectionStatus.draft,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        ]),
      );
    },
    act: (InspectionsBloc bloc) => bloc.add(const InspectionsStarted()),
    expect: () => <dynamic>[
      const InspectionsLoading(),
      isA<InspectionsLoaded>(),
    ],
  );

  blocTest<InspectionsBloc, InspectionsState>(
    'emits empty when no inspections',
    build: () => InspectionsBloc(repository: repository),
    setUp: () {
      when(() => repository.getInspections()).thenAnswer(
        (_) async => const Success<List<InspectionEntity>>(<InspectionEntity>[]),
      );
    },
    act: (InspectionsBloc bloc) => bloc.add(const InspectionsStarted()),
    expect: () => <InspectionsState>[
      const InspectionsLoading(),
      const InspectionsEmpty(),
    ],
  );

  blocTest<InspectionsBloc, InspectionsState>(
    'emits failure when repository fails',
    build: () => InspectionsBloc(repository: repository),
    setUp: () {
      when(() => repository.getInspections()).thenAnswer(
        (_) async => const Error<List<InspectionEntity>>(
          DatabaseFailure(message: 'Failed to load'),
        ),
      );
    },
    act: (InspectionsBloc bloc) => bloc.add(const InspectionsRefreshed()),
    expect: () => <InspectionsState>[
      const InspectionsLoading(),
      const InspectionsFailure('Failed to load'),
    ],
  );
}
