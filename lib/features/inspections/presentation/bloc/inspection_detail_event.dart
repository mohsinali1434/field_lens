import 'package:equatable/equatable.dart';

sealed class InspectionDetailEvent extends Equatable {
  const InspectionDetailEvent();
  @override
  List<Object?> get props => <Object?>[];
}

final class InspectionDetailStarted extends InspectionDetailEvent {
  const InspectionDetailStarted(this.inspectionId);
  final String inspectionId;
  @override
  List<Object?> get props => <Object?>[inspectionId];
}

final class InspectionDetailRefreshed extends InspectionDetailEvent {
  const InspectionDetailRefreshed();
}

final class InspectionStatusChanged extends InspectionDetailEvent {
  const InspectionStatusChanged(this.statusValue);
  final String statusValue;
  @override
  List<Object?> get props => <Object?>[statusValue];
}

final class InspectionArchived extends InspectionDetailEvent {
  const InspectionArchived();
}
