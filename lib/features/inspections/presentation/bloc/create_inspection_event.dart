import 'package:equatable/equatable.dart';
import 'package:field_lens/features/inspections/domain/usecases/create_inspection.dart';

sealed class CreateInspectionEvent extends Equatable {
  const CreateInspectionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class CreateInspectionSubmitted extends CreateInspectionEvent {
  const CreateInspectionSubmitted(this.input);

  final CreateInspectionInput input;

  @override
  List<Object?> get props => <Object?>[input];
}
