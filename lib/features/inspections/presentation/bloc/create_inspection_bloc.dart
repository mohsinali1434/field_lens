import 'package:field_lens/features/inspections/domain/usecases/create_inspection.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Handles new inspection form submission.
class CreateInspectionBloc
    extends Bloc<CreateInspectionEvent, CreateInspectionState> {
  CreateInspectionBloc({required CreateInspectionUseCase createInspection})
    : _createInspection = createInspection,
      super(const CreateInspectionInitial()) {
    on<CreateInspectionSubmitted>(_onSubmitted);
  }

  final CreateInspectionUseCase _createInspection;

  Future<void> _onSubmitted(
    CreateInspectionSubmitted event,
    Emitter<CreateInspectionState> emit,
  ) async {
    emit(const CreateInspectionSubmitting());

    final result = await _createInspection(event.input);
    result.fold(
      onSuccess: (inspection) =>
          emit(CreateInspectionSuccess(inspection.id)),
      onFailure: (failure) => emit(CreateInspectionFailure(failure.message)),
    );
  }
}
