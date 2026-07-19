import 'package:equatable/equatable.dart';
import '../entity/branch_dto.dart';
import '../entity/business_analysis_report_dto.dart';
import '../entity/medicine_statistics_dto.dart';
import '../entity/profile_dto.dart';

sealed class BusinessAdminState extends Equatable {
  const BusinessAdminState();

  @override
  List<Object?> get props => [];
}

final class BusinessAdminInitial extends BusinessAdminState {}

final class BusinessAdminLoading extends BusinessAdminState {}

final class BusinessAdminOperationSuccess extends BusinessAdminState {
  final String message;

  const BusinessAdminOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BusinessAdminProfileLoadSuccess extends BusinessAdminState {
  final ProfileDto profile;

  const BusinessAdminProfileLoadSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

final class BusinessAdminProfileOperationSuccess
    extends BusinessAdminProfileLoadSuccess {
  final String message;

  const BusinessAdminProfileOperationSuccess(super.profile, this.message);

  @override
  List<Object?> get props => [...super.props, message];
}

final class BranchesLoadSuccess extends BusinessAdminState {
  final List<BranchDto> branches;

  const BranchesLoadSuccess(this.branches);

  @override
  List<Object?> get props => [branches];
}

final class MedicineStatisticsLoadSuccess extends BusinessAdminState {
  final MedicineStatisticsDto statistics;

  const MedicineStatisticsLoadSuccess(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

final class BusinessAnalysisReportLoadSuccess extends BusinessAdminState {
  final BusinessAnalysisReportDto report;

  const BusinessAnalysisReportLoadSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

final class BusinessAdminLoadFailure extends BusinessAdminState {
  final String message;

  const BusinessAdminLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
