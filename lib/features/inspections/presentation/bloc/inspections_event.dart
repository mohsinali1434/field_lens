import 'package:equatable/equatable.dart';

sealed class InspectionsEvent extends Equatable {
  const InspectionsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class InspectionsStarted extends InspectionsEvent {
  const InspectionsStarted();
}

final class InspectionsRefreshed extends InspectionsEvent {
  const InspectionsRefreshed();
}
