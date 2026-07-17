import 'package:equatable/equatable.dart';

import '../entity/staff_management_dto.dart';

sealed class StaffPerformanceEvent extends Equatable {
  const StaffPerformanceEvent();

  @override
  List<Object?> get props => [];
}

final class StaffPerformanceFetchRequested extends StaffPerformanceEvent {
  final String? search;
  final String status;
  final String sort;

  const StaffPerformanceFetchRequested({
    this.search,
    this.status = 'all',
    this.sort = 'revenue_desc',
  });

  @override
  List<Object?> get props => [search, status, sort];
}

final class BranchStaffCreateRequested extends StaffPerformanceEvent {
  final CreateBranchStaffRequestDto request;

  const BranchStaffCreateRequested(this.request);

  @override
  List<Object?> get props => [request];
}

final class StaffShiftUpsertRequested extends StaffPerformanceEvent {
  final UpsertStaffShiftRequestDto request;

  const StaffShiftUpsertRequested(this.request);

  @override
  List<Object?> get props => [request];
}

final class StaffAssessmentCreateRequested extends StaffPerformanceEvent {
  final CreateStaffAssessmentRequestDto request;

  const StaffAssessmentCreateRequested(this.request);

  @override
  List<Object?> get props => [request];
}
