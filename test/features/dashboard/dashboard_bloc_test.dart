import 'package:bloc_test/bloc_test.dart';
import 'package:field_lens/core/demo/demo_data_seeder.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/dashboard/domain/models/dashboard_overview.dart';
import 'package:field_lens/features/dashboard/domain/usecases/get_dashboard_overview.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetDashboardOverview extends Mock
    implements GetDashboardOverviewUseCase {}

class _MockDemoDataSeeder extends Mock implements DemoDataSeeder {}

void main() {
  late _MockGetDashboardOverview getDashboardOverview;
  late _MockDemoDataSeeder demoDataSeeder;

  setUp(() {
    getDashboardOverview = _MockGetDashboardOverview();
    demoDataSeeder = _MockDemoDataSeeder();
    when(() => demoDataSeeder.seedIfNeeded())
        .thenAnswer((_) async => const Success<void>(null));
  });

  blocTest<DashboardBloc, DashboardState>(
    'loads dashboard overview on start',
    build: () => DashboardBloc(
      getDashboardOverview: getDashboardOverview,
      demoDataSeeder: demoDataSeeder,
    ),
    setUp: () {
      when(() => getDashboardOverview()).thenAnswer(
        (_) async => Success<DashboardOverview>(
          DashboardOverview(
            activeInspections: 2,
            completedInspections: 1,
            pendingReports: 0,
            recentInspections: <RecentInspectionItem>[
              RecentInspectionItem(
                id: '1',
                title: 'Recent',
                location: 'Site',
                date: DateTime.utc(2026),
                status: InspectionStatus.inProgress,
                observationCount: 3,
                completionPercent: 50,
              ),
            ],
          ),
        ),
      );
    },
    act: (DashboardBloc bloc) => bloc.add(const DashboardStarted()),
    expect: () => <dynamic>[
      const DashboardLoading(),
      isA<DashboardLoaded>(),
    ],
    verify: (_) {
      verify(() => demoDataSeeder.seedIfNeeded()).called(1);
    },
  );

  blocTest<DashboardBloc, DashboardState>(
    'emits failure when overview load fails',
    build: () => DashboardBloc(
      getDashboardOverview: getDashboardOverview,
      demoDataSeeder: demoDataSeeder,
    ),
    setUp: () {
      when(() => getDashboardOverview()).thenAnswer(
        (_) async => const Error<DashboardOverview>(
          DatabaseFailure(message: 'Load failed'),
        ),
      );
    },
    act: (DashboardBloc bloc) => bloc.add(const DashboardRefreshed()),
    expect: () => <DashboardState>[
      const DashboardLoading(),
      const DashboardFailure('Load failed'),
    ],
    verify: (_) {
      verifyNever(() => demoDataSeeder.seedIfNeeded());
    },
  );
}
