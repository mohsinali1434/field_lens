import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/search/domain/usecases/search_data.dart';
import 'package:field_lens/features/search/presentation/bloc/search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SearchBloc bloc;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final searchData = SearchData(
      inspectionRepository: InspectionRepositoryImpl(database),
      observationRepository: ObservationRepositoryImpl(database),
    );
    bloc = SearchBloc(searchData: searchData);

    final now = DateTime.utc(2026, 1, 1);
    await InspectionRepositoryImpl(database).saveInspection(
      InspectionEntity(
        id: 'insp-bloc',
        title: 'Roof Inspection',
        clientName: 'Client',
        siteName: 'Site',
        description: 'Annual roof check',
        status: InspectionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await bloc.close();
    await database.close();
  });

  blocTest<SearchBloc, SearchState>(
    'emits initial for empty query',
    build: () => bloc,
    act: (SearchBloc b) => b.add(const SearchQueryChanged('')),
    expect: () => <SearchState>[const SearchInitial()],
  );

  blocTest<SearchBloc, SearchState>(
    'emits loaded when results found',
    build: () => bloc,
    act: (SearchBloc b) => b.add(const SearchQueryChanged('roof')),
    expect: () => <dynamic>[
      const SearchLoading(),
      isA<SearchLoaded>(),
    ],
    verify: (SearchBloc b) {
      final state = b.state as SearchLoaded;
      expect(state.results.inspections, hasLength(1));
      expect(state.query, 'roof');
    },
  );

  blocTest<SearchBloc, SearchState>(
    'emits empty when no matches',
    build: () => bloc,
    act: (SearchBloc b) => b.add(const SearchQueryChanged('missing-term')),
    expect: () => <SearchState>[
      const SearchLoading(),
      const SearchEmpty('missing-term'),
    ],
  );
}
