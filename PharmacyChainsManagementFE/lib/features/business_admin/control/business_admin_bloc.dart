import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/network_exceptions.dart';
import '../network/business_admin_api_client.dart';
import 'business_admin_event.dart';
import 'business_admin_state.dart';

class BusinessAdminBloc extends Bloc<BusinessAdminEvent, BusinessAdminState> {
  final BusinessAdminApiClient businessAdminApiClient;

  BusinessAdminBloc({required this.businessAdminApiClient})
    : super(BusinessAdminInitial()) {
    on<BusinessAdminProfileFetchRequested>(_onProfileFetchRequested);
    on<BusinessAdminProfileUpdateSubmitted>(_onProfileUpdateSubmitted);
    on<BusinessAdminForgotPasswordRequested>(_onForgotPasswordRequested);
    on<BusinessAdminPasswordResetSubmitted>(_onPasswordResetSubmitted);
    on<BranchesFetchRequested>(_onBranchesFetchRequested);
    on<BranchCreateSubmitted>(_onBranchCreateSubmitted);
    on<BranchUpdateSubmitted>(_onBranchUpdateSubmitted);
    on<MedicineStatisticsFetchRequested>(_onMedicineStatisticsFetchRequested);
    on<BusinessAnalysisReportFetchRequested>(
      _onBusinessAnalysisReportFetchRequested,
    );
  }

  Future<void> _onProfileFetchRequested(
    BusinessAdminProfileFetchRequested event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      final profile = await businessAdminApiClient.fetchProfile();
      emit(BusinessAdminProfileLoadSuccess(profile));
    });
  }

  Future<void> _onProfileUpdateSubmitted(
    BusinessAdminProfileUpdateSubmitted event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      final profile = await businessAdminApiClient.updateProfile(event.request);
      emit(BusinessAdminProfileLoadSuccess(profile));
    });
  }

  Future<void> _onForgotPasswordRequested(
    BusinessAdminForgotPasswordRequested event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      await businessAdminApiClient.requestForgotPassword(event.request);
      emit(const BusinessAdminOperationSuccess('Password reset email sent.'));
    });
  }

  Future<void> _onPasswordResetSubmitted(
    BusinessAdminPasswordResetSubmitted event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      await businessAdminApiClient.resetPassword(event.request);
      emit(const BusinessAdminOperationSuccess('Password has been reset.'));
    });
  }

  Future<void> _onBranchesFetchRequested(
    BranchesFetchRequested event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      final branches = await businessAdminApiClient.fetchBranches(
        search: event.search,
        status: event.status,
      );
      emit(BranchesLoadSuccess(branches));
    });
  }

  Future<void> _onBranchCreateSubmitted(
    BranchCreateSubmitted event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      await businessAdminApiClient.createBranch(event.request);
      final branches = await businessAdminApiClient.fetchBranches();
      emit(BranchesLoadSuccess(branches));
    });
  }

  Future<void> _onBranchUpdateSubmitted(
    BranchUpdateSubmitted event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      await businessAdminApiClient.updateBranch(event.branchId, event.request);
      final branches = await businessAdminApiClient.fetchBranches();
      emit(BranchesLoadSuccess(branches));
    });
  }

  Future<void> _onMedicineStatisticsFetchRequested(
    MedicineStatisticsFetchRequested event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      final statistics = await businessAdminApiClient.fetchMedicineStatistics(
        event.filter,
      );
      emit(MedicineStatisticsLoadSuccess(statistics));
    });
  }

  Future<void> _onBusinessAnalysisReportFetchRequested(
    BusinessAnalysisReportFetchRequested event,
    Emitter<BusinessAdminState> emit,
  ) async {
    emit(BusinessAdminLoading());
    await _guard(emit, () async {
      final report = await businessAdminApiClient.fetchBusinessAnalysisReport(
        event.filter,
      );
      emit(BusinessAnalysisReportLoadSuccess(report));
    });
  }

  Future<void> _guard(
    Emitter<BusinessAdminState> emit,
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
    } on AppException catch (error) {
      emit(BusinessAdminLoadFailure(error.message));
    } catch (_) {
      emit(const BusinessAdminLoadFailure('An unknown error occurred.'));
    }
  }
}
