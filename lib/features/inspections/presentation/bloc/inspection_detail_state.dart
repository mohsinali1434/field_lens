import 'package:equatable/equatable.dart';
import 'package:field_lens/features/inspections/domain/models/inspection_workspace.dart';

sealed class InspectionDetailState extends Equatable {
  const InspectionDetailState();
  @override
  List<Object?> get props => <Object?>[];
}

final class InspectionDetailInitial extends InspectionDetailState {
  const InspectionDetailInitial();
}

final class InspectionDetailLoading extends InspectionDetailState {
  const InspectionDetailLoading();
}

final class InspectionDetailLoaded extends InspectionDetailState {
  const InspectionDetailLoaded(this.workspace);
  final InspectionWorkspace workspace;
  @override
  List<Object?> get props => <Object?>[workspace];
}

final class InspectionDetailFailure extends InspectionDetailState {
  const InspectionDetailFailure(this.message);
  final String message;
  @override
  List<Object?> get props => <Object?>[message];
}
