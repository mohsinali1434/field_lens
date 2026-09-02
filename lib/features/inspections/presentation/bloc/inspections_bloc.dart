import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads the inspections list.
class InspectionsBloc extends Bloc<InspectionsEvent, InspectionsState> {
  InspectionsBloc({required InspectionRepository repository})
    : _repository = repository,
      super(const InspectionsInitial()) {
    on<InspectionsStarted>(_onStarted);
    on<InspectionsRefreshed>(_onRefreshed);
  }

  final InspectionRepository _repository;

  Future<void> _onStarted(
    InspectionsStarted event,
    Emitter<InspectionsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRefreshed(
    InspectionsRefreshed event,
    Emitter<InspectionsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<InspectionsState> emit) async {
    emit(const InspectionsLoading());
    final result = await _repository.getInspections();
    result.fold(
      onSuccess: (inspections) {
        if (inspections.isEmpty) {
          emit(const InspectionsEmpty());
        } else {
          emit(InspectionsLoaded(inspections));
        }
      },
      onFailure: (failure) => emit(InspectionsFailure(failure.message)),
    );
  }
}
