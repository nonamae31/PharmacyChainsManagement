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
  final DateTime? shiftDate;

  const StaffPerformanceFetchRequested({
    this.search,
    this.status = 'all',
    this.sort = 'revenue_desc',
    this.shiftDate,
  });

  @override
  List<Object?> get props => [search, status, sort, shiftDate];
}

final class StaffShiftDateSelected extends StaffPerformanceEvent {
  final DateTime date;

  const StaffShiftDateSelected(this.date);

  @override
  List<Object?> get props => [date];
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

final class StaffStatusUpdateRequested extends StaffPerformanceEvent {
  final UpdateStaffStatusRequestDto request;

  const StaffStatusUpdateRequested(this.request);

  @override
  List<Object?> get props => [request];
}
