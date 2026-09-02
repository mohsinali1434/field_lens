import 'package:equatable/equatable.dart';

sealed class CreateInspectionState extends Equatable {
  const CreateInspectionState();

  @override
  List<Object?> get props => <Object?>[];
}

final class CreateInspectionInitial extends CreateInspectionState {
  const CreateInspectionInitial();
}

final class CreateInspectionSubmitting extends CreateInspectionState {
  const CreateInspectionSubmitting();
}

final class CreateInspectionSuccess extends CreateInspectionState {
  const CreateInspectionSuccess(this.inspectionId);

  final String inspectionId;

  @override
  List<Object?> get props => <Object?>[inspectionId];
}

final class CreateInspectionFailure extends CreateInspectionState {
  const CreateInspectionFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
