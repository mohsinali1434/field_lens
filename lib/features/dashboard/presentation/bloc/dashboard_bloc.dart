import 'package:field_lens/core/demo/demo_data_seeder.dart';
import 'package:field_lens/features/dashboard/domain/usecases/get_dashboard_overview.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages dashboard overview loading and refresh.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required GetDashboardOverviewUseCase getDashboardOverview,
    required DemoDataSeeder demoDataSeeder,
  }) : _getDashboardOverview = getDashboardOverview,
       _demoDataSeeder = demoDataSeeder,
       super(const DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onRefreshed);
  }

  final GetDashboardOverviewUseCase _getDashboardOverview;
  final DemoDataSeeder _demoDataSeeder;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    await _load(emit, seedDemo: true);
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    await _load(emit, seedDemo: false);
  }

  Future<void> _load(Emitter<DashboardState> emit, {required bool seedDemo}) async {
    emit(const DashboardLoading());

    if (seedDemo) {
      await _demoDataSeeder.seedIfNeeded();
    }

    final result = await _getDashboardOverview();
    result.fold(
      onSuccess: (overview) {
        if (overview.isEmpty) {
          emit(DashboardEmpty(overview));
        } else {
          emit(DashboardLoaded(overview));
        }
      },
      onFailure: (failure) => emit(DashboardFailure(failure.message)),
    );
  }
}
