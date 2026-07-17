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

class StaffPerformanceLoadSuccess extends StaffPerformanceState {
  final StaffPerformanceDto performance;
  final String search;
  final String status;
  final String sort;

  const StaffPerformanceLoadSuccess(
    this.performance, {
    this.search = '',
    this.status = 'all',
    this.sort = 'revenue_desc',
  });

  @override
  List<Object?> get props => [performance, search, status, sort];
}

final class StaffPerformanceOperationSuccess
    extends StaffPerformanceLoadSuccess {
  final String message;

  const StaffPerformanceOperationSuccess(
    super.performance, {
    required super.search,
    required super.status,
    required super.sort,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

final class StaffPerformanceLoadFailure extends StaffPerformanceState {
  final String message;

  const StaffPerformanceLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
