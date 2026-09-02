import 'package:equatable/equatable.dart';
import 'package:field_lens/features/dashboard/domain/models/dashboard_overview.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => <Object?>[];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.overview);

  final DashboardOverview overview;

  @override
  List<Object?> get props => <Object?>[overview];
}

final class DashboardEmpty extends DashboardState {
  const DashboardEmpty(this.overview);

  final DashboardOverview overview;

  @override
  List<Object?> get props => <Object?>[overview];
}

final class DashboardFailure extends DashboardState {
  const DashboardFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
