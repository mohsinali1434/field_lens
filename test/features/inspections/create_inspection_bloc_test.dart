import 'package:bloc_test/bloc_test.dart';
import 'package:field_lens/features/inspections/domain/usecases/create_inspection.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';

class _MockCreateInspectionUseCase extends Mock
    implements CreateInspectionUseCase {}

void main() {
  late _MockCreateInspectionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const CreateInspectionInput(
        title: 't',
        clientName: 'c',
        siteName: 's',
        description: 'd',
      ),
    );
  });

  setUp(() {
    useCase = _MockCreateInspectionUseCase();
  });

  blocTest<CreateInspectionBloc, CreateInspectionState>(
    'emits success when inspection is created',
    build: () => CreateInspectionBloc(createInspection: useCase),
    act: (CreateInspectionBloc bloc) => bloc.add(
      const CreateInspectionSubmitted(
        CreateInspectionInput(
          title: 'Test',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
        ),
      ),
    ),
    setUp: () {
      when(() => useCase(any())).thenAnswer(
        (_) async => Success<InspectionEntity>(
          InspectionEntity(
            id: 'new-id',
            title: 'Test',
            clientName: 'Client',
            siteName: 'Site',
            description: 'Desc',
            status: InspectionStatus.draft,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        ),
      );
    },
    expect: () => <CreateInspectionState>[
      const CreateInspectionSubmitting(),
      const CreateInspectionSuccess('new-id'),
    ],
  );

  blocTest<CreateInspectionBloc, CreateInspectionState>(
    'emits failure when use case fails',
    build: () => CreateInspectionBloc(createInspection: useCase),
    act: (CreateInspectionBloc bloc) => bloc.add(
      const CreateInspectionSubmitted(
        CreateInspectionInput(
          title: 'Test',
          clientName: 'Client',
          siteName: 'Site',
          description: 'Desc',
        ),
      ),
    ),
    setUp: () {
      when(() => useCase(any())).thenAnswer(
        (_) async => const Error<InspectionEntity>(
          DatabaseFailure(message: 'Failed'),
        ),
      );
    },
    expect: () => <CreateInspectionState>[
      const CreateInspectionSubmitting(),
      const CreateInspectionFailure('Failed'),
    ],
  );
}
