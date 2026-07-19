import 'package:equatable/equatable.dart';
import '../entity/branch_dto.dart';
import '../entity/business_analysis_report_dto.dart';
import '../entity/forgot_password_dto.dart';
import '../entity/medicine_statistics_dto.dart';
import '../entity/profile_dto.dart';

sealed class BusinessAdminEvent extends Equatable {
  const BusinessAdminEvent();

  @override
  List<Object?> get props => [];
}

final class BusinessAdminProfileFetchRequested extends BusinessAdminEvent {}

final class BusinessAdminProfileUpdateSubmitted extends BusinessAdminEvent {
  final UpdateProfileRequestDto request;

  const BusinessAdminProfileUpdateSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

final class BusinessAdminForgotPasswordRequested extends BusinessAdminEvent {
  final ForgotPasswordRequestDto request;

  const BusinessAdminForgotPasswordRequested(this.request);

  @override
  List<Object?> get props => [request];
}

final class BusinessAdminPasswordResetSubmitted extends BusinessAdminEvent {
  final ResetPasswordRequestDto request;

  const BusinessAdminPasswordResetSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

final class BranchesFetchRequested extends BusinessAdminEvent {
  final String? search;
  final String? status;

  const BranchesFetchRequested({this.search, this.status});

  @override
  List<Object?> get props => [search, status];
}

final class BranchCreateSubmitted extends BusinessAdminEvent {
  final BranchRequestDto request;

  const BranchCreateSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

final class BranchUpdateSubmitted extends BusinessAdminEvent {
  final String branchId;
  final BranchRequestDto request;

  const BranchUpdateSubmitted({required this.branchId, required this.request});

  @override
  List<Object?> get props => [branchId, request];
}

final class BranchManagerAccountCreateSubmitted extends BusinessAdminEvent {
  final String branchId;
  final BranchManagerAccountRequestDto request;

  const BranchManagerAccountCreateSubmitted({
    required this.branchId,
    required this.request,
  });

  @override
  List<Object?> get props => [branchId, request];
}

final class BranchManagerAccountUpdateSubmitted extends BusinessAdminEvent {
  final String branchId;
  final String managerId;
  final BranchManagerAccountRequestDto request;

  const BranchManagerAccountUpdateSubmitted({
    required this.branchId,
    required this.managerId,
    required this.request,
  });

  @override
  List<Object?> get props => [branchId, managerId, request];
}

final class BranchManagerAccountPasswordResetRequested
    extends BusinessAdminEvent {
  final String branchId;
  final String managerId;

  const BranchManagerAccountPasswordResetRequested({
    required this.branchId,
    required this.managerId,
  });

  @override
  List<Object?> get props => [branchId, managerId];
}

final class BranchManagerAccountDeleteRequested extends BusinessAdminEvent {
  final String branchId;
  final String managerId;

  const BranchManagerAccountDeleteRequested({
    required this.branchId,
    required this.managerId,
  });

  @override
  List<Object?> get props => [branchId, managerId];
}

final class MedicineStatisticsFetchRequested extends BusinessAdminEvent {
  final MedicineStatisticsFilterDto filter;

  const MedicineStatisticsFetchRequested(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class BusinessAnalysisReportFetchRequested extends BusinessAdminEvent {
  final BusinessAnalysisFilterDto filter;

  const BusinessAnalysisReportFetchRequested(this.filter);

  @override
  List<Object?> get props => [filter];
}
