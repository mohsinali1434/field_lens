import 'package:equatable/equatable.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';

sealed class InspectionsState extends Equatable {
  const InspectionsState();

  @override
  List<Object?> get props => <Object?>[];
}

final class InspectionsInitial extends InspectionsState {
  const InspectionsInitial();
}

final class InspectionsLoading extends InspectionsState {
  const InspectionsLoading();
}

final class InspectionsLoaded extends InspectionsState {
  const InspectionsLoaded(this.inspections);

  final List<InspectionEntity> inspections;

  @override
  List<Object?> get props => <Object?>[inspections];
}

final class InspectionsEmpty extends InspectionsState {
  const InspectionsEmpty();
}

final class InspectionsFailure extends InspectionsState {
  const InspectionsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
