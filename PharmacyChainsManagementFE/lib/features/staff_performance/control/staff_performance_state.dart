import 'package:equatable/equatable.dart';

import '../entity/staff_performance_dto.dart';

sealed class StaffPerformanceState extends Equatable {
  const StaffPerformanceState();

  @override
  List<Object?> get props => [];
}

final class StaffPerformanceInitial extends StaffPerformanceState {
  const StaffPerformanceInitial();
}

final class StaffPerformanceLoading extends StaffPerformanceState {
  const StaffPerformanceLoading();
}

final class StaffPerformanceLoadSuccess extends StaffPerformanceState {
  final StaffPerformanceDto performance;

  const StaffPerformanceLoadSuccess(this.performance);

  @override
  List<Object?> get props => [performance];
}

final class StaffPerformanceLoadFailure extends StaffPerformanceState {
  final String message;

  const StaffPerformanceLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
