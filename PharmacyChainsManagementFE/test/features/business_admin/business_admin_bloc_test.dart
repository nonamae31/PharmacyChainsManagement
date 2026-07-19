import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/core/network/network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/control/business_admin_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/control/business_admin_event.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/control/business_admin_state.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/branch_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/business_analysis_report_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/forgot_password_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/medicine_statistics_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/profile_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/network/business_admin_api_client.dart';

void main() {
  group('BusinessAdminBloc', () {
    late _FakeBusinessAdminApiClient apiClient;
    late BusinessAdminBloc bloc;

    setUp(() {
      apiClient = _FakeBusinessAdminApiClient();
      bloc = BusinessAdminBloc(businessAdminApiClient: apiClient);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('loads business admin profile successfully', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BusinessAdminProfileLoadSuccess &&
                state.profile.email == 'businessadmin@pharmacy.com' &&
                state.profile.role == 'BUSINESS_ADMIN',
          ),
        ]),
      );

      bloc.add(BusinessAdminProfileFetchRequested());

      await expectation;
      expect(apiClient.fetchProfileCallCount, 1);
    });

    test('updates profile and emits updated profile', () async {
      const request = UpdateProfileRequestDto(
        fullName: 'Updated Business Admin',
        phone: '0987654321',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BusinessAdminProfileLoadSuccess &&
                state.profile.fullName == request.fullName &&
                state.profile.phone == request.phone,
          ),
        ]),
      );

      bloc.add(const BusinessAdminProfileUpdateSubmitted(request));

      await expectation;
      expect(apiClient.lastProfileUpdateRequest, request);
    });

    test('sends forgot password email successfully', () async {
      const request = ForgotPasswordRequestDto('businessadmin@pharmacy.com');

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BusinessAdminOperationSuccess &&
                state.message == 'Password reset email sent.',
          ),
        ]),
      );

      bloc.add(const BusinessAdminForgotPasswordRequested(request));

      await expectation;
      expect(apiClient.lastForgotPasswordRequest, request);
    });

    test('resets password successfully', () async {
      const request = ResetPasswordRequestDto(
        email: 'businessadmin@pharmacy.com',
        token: '123456',
        newPassword: 'NewPassword@123',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BusinessAdminOperationSuccess &&
                state.message == 'Password has been reset.',
          ),
        ]),
      );

      bloc.add(const BusinessAdminPasswordResetSubmitted(request));

      await expectation;
      expect(apiClient.lastResetPasswordRequest, request);
    });

    test('loads branches with requested filters', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BranchesLoadSuccess &&
                state.branches.length == 2 &&
                state.branches.first.branchName == 'Bach Mai Hospital Pharmacy',
          ),
        ]),
      );

      bloc.add(
        const BranchesFetchRequested(search: 'Bach Mai', status: 'ACTIVE'),
      );

      await expectation;
      expect(apiClient.lastBranchSearch, 'Bach Mai');
      expect(apiClient.lastBranchStatus, 'ACTIVE');
    });

    test('creates branch then refreshes branch list', () async {
      const request = BranchRequestDto(
        branchName: 'New Pharmacy',
        address: '1 Test Street',
        status: 'ACTIVE',
        phone: '02439999999',
        latitude: 21.0285,
        longitude: 105.8542,
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BranchesLoadSuccess &&
                state.branches.any(
                  (branch) => branch.branchName == request.branchName,
                ),
          ),
        ]),
      );

      bloc.add(const BranchCreateSubmitted(request));

      await expectation;
      expect(apiClient.lastBranchCreateRequest, request);
      expect(apiClient.fetchBranchesCallCount, 1);
    });

    test('updates branch then refreshes branch list', () async {
      const request = BranchRequestDto(
        branchName: 'Updated Pharmacy',
        address: '2 Test Street',
        status: 'ACTIVE',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          isA<BranchesLoadSuccess>(),
        ]),
      );

      bloc.add(
        const BranchUpdateSubmitted(branchId: 'branch-1', request: request),
      );

      await expectation;
      expect(apiClient.lastBranchUpdateId, 'branch-1');
      expect(apiClient.lastBranchUpdateRequest, request);
      expect(apiClient.fetchBranchesCallCount, 1);
    });

    test('creates branch manager account then refreshes branches', () async {
      const request = BranchManagerAccountRequestDto(
        fullName: 'Branch Manager',
        email: 'manager@pharmacy.com',
        status: 'ACTIVE',
        phone: '0901111222',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          isA<BranchesLoadSuccess>(),
        ]),
      );

      bloc.add(
        const BranchManagerAccountCreateSubmitted(
          branchId: 'branch-1',
          request: request,
        ),
      );

      await expectation;
      expect(apiClient.lastManagerAccountBranchId, 'branch-1');
      expect(apiClient.lastManagerAccountRequest, request);
      expect(apiClient.fetchBranchesCallCount, 1);
    });

    test('updates branch manager account then refreshes branches', () async {
      const request = BranchManagerAccountRequestDto(
        fullName: 'Updated Manager',
        email: 'updated.manager@pharmacy.com',
        status: 'ACTIVE',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          isA<BranchesLoadSuccess>(),
        ]),
      );

      bloc.add(
        const BranchManagerAccountUpdateSubmitted(
          branchId: 'branch-1',
          managerId: 'manager-1',
          request: request,
        ),
      );

      await expectation;
      expect(apiClient.lastManagerAccountBranchId, 'branch-1');
      expect(apiClient.lastManagerAccountManagerId, 'manager-1');
      expect(apiClient.lastManagerAccountRequest, request);
      expect(apiClient.fetchBranchesCallCount, 1);
    });

    test('resets branch manager password then refreshes branches', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          isA<BranchesLoadSuccess>(),
        ]),
      );

      bloc.add(
        const BranchManagerAccountPasswordResetRequested(
          branchId: 'branch-1',
          managerId: 'manager-1',
        ),
      );

      await expectation;
      expect(apiClient.lastManagerPasswordResetBranchId, 'branch-1');
      expect(apiClient.lastManagerPasswordResetManagerId, 'manager-1');
      expect(apiClient.fetchBranchesCallCount, 1);
    });

    test('deletes branch manager account then refreshes branches', () async {
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          isA<BranchesLoadSuccess>(),
        ]),
      );

      bloc.add(
        const BranchManagerAccountDeleteRequested(
          branchId: 'branch-1',
          managerId: 'manager-1',
        ),
      );

      await expectation;
      expect(apiClient.lastManagerDeleteBranchId, 'branch-1');
      expect(apiClient.lastManagerDeleteManagerId, 'manager-1');
      expect(apiClient.fetchBranchesCallCount, 1);
    });

    test('loads medicine statistics successfully', () async {
      const filter = MedicineStatisticsFilterDto(
        search: 'Amoxicillin',
        category: 'Antibiotic',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is MedicineStatisticsLoadSuccess &&
                state.statistics.totalMedicines == 15 &&
                state.statistics.inventoryItems.first.medicineName ==
                    'Amoxicillin 500mg',
          ),
        ]),
      );

      bloc.add(const MedicineStatisticsFetchRequested(filter));

      await expectation;
      expect(apiClient.lastMedicineStatisticsFilter, filter);
    });

    test('loads business analysis report successfully', () async {
      final filter = BusinessAnalysisFilterDto(
        fromDate: DateTime(2026, 7),
        toDate: DateTime(2026, 7, 31),
        viewMode: 'detailed',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BusinessAnalysisReportLoadSuccess &&
                state.report.summary.totalRevenue == 12889577 &&
                state.report.branchFinancialSummary.first.branchName ==
                    'Bach Mai Hospital Pharmacy',
          ),
        ]),
      );

      bloc.add(BusinessAnalysisReportFetchRequested(filter));

      await expectation;
      expect(apiClient.lastBusinessAnalysisFilter, filter);
    });

    test('emits load failure when api client throws AppException', () async {
      apiClient.exceptionToThrow = const UnauthorizedException();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BusinessAdminLoadFailure &&
                state.message == 'Your session has expired.',
          ),
        ]),
      );

      bloc.add(BusinessAdminProfileFetchRequested());

      await expectation;
    });

    test('emits unknown failure when api client throws unexpected error', () async {
      apiClient.unexpectedErrorToThrow = StateError('broken test api');

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BusinessAdminLoading>(),
          predicate<BusinessAdminState>(
            (state) =>
                state is BusinessAdminLoadFailure &&
                state.message == 'An unknown error occurred.',
          ),
        ]),
      );

      bloc.add(BusinessAdminProfileFetchRequested());

      await expectation;
    });
  });
}

class _FakeBusinessAdminApiClient extends BusinessAdminApiClient {
  _FakeBusinessAdminApiClient() : super(dio: Dio());

  int fetchProfileCallCount = 0;
  int fetchBranchesCallCount = 0;
  final List<BranchDto> createdBranches = [];
  AppException? exceptionToThrow;
  Object? unexpectedErrorToThrow;
  UpdateProfileRequestDto? lastProfileUpdateRequest;
  ForgotPasswordRequestDto? lastForgotPasswordRequest;
  ResetPasswordRequestDto? lastResetPasswordRequest;
  String? lastBranchSearch;
  String? lastBranchStatus;
  BranchRequestDto? lastBranchCreateRequest;
  String? lastBranchUpdateId;
  BranchRequestDto? lastBranchUpdateRequest;
  String? lastManagerAccountBranchId;
  String? lastManagerAccountManagerId;
  BranchManagerAccountRequestDto? lastManagerAccountRequest;
  String? lastManagerPasswordResetBranchId;
  String? lastManagerPasswordResetManagerId;
  String? lastManagerDeleteBranchId;
  String? lastManagerDeleteManagerId;
  MedicineStatisticsFilterDto? lastMedicineStatisticsFilter;
  BusinessAnalysisFilterDto? lastBusinessAnalysisFilter;

  void _throwIfNeeded() {
    final appException = exceptionToThrow;
    if (appException != null) throw appException;

    final unexpectedError = unexpectedErrorToThrow;
    if (unexpectedError != null) throw unexpectedError;
  }

  @override
  Future<ProfileDto> fetchProfile() async {
    _throwIfNeeded();
    fetchProfileCallCount += 1;
    return _profile();
  }

  @override
  Future<ProfileDto> updateProfile(UpdateProfileRequestDto request) async {
    _throwIfNeeded();
    lastProfileUpdateRequest = request;
    return _profile(fullName: request.fullName, phone: request.phone);
  }

  @override
  Future<void> requestForgotPassword(ForgotPasswordRequestDto request) async {
    _throwIfNeeded();
    lastForgotPasswordRequest = request;
  }

  @override
  Future<void> resetPassword(ResetPasswordRequestDto request) async {
    _throwIfNeeded();
    lastResetPasswordRequest = request;
  }

  @override
  Future<List<BranchDto>> fetchBranches({
    String? search,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    _throwIfNeeded();
    fetchBranchesCallCount += 1;
    lastBranchSearch = search;
    lastBranchStatus = status;
    return [..._branches(), ...createdBranches];
  }

  @override
  Future<BranchDto> createBranch(BranchRequestDto request) async {
    _throwIfNeeded();
    lastBranchCreateRequest = request;
    final branch = _branch(
      branchId: 'branch-new',
      branchName: request.branchName,
      address: request.address,
      status: request.status,
      phone: request.phone,
      latitude: request.latitude,
      longitude: request.longitude,
    );
    createdBranches.add(branch);
    return branch;
  }

  @override
  Future<BranchDto> updateBranch(
    String branchId,
    BranchRequestDto request,
  ) async {
    _throwIfNeeded();
    lastBranchUpdateId = branchId;
    lastBranchUpdateRequest = request;
    return _branch(
      branchId: branchId,
      branchName: request.branchName,
      address: request.address,
      status: request.status,
      phone: request.phone,
      latitude: request.latitude,
      longitude: request.longitude,
    );
  }

  @override
  Future<BranchDto> createBranchManagerAccount(
    String branchId,
    BranchManagerAccountRequestDto request,
  ) async {
    _throwIfNeeded();
    lastManagerAccountBranchId = branchId;
    lastManagerAccountRequest = request;
    return _branch(branchId: branchId, managerName: request.fullName);
  }

  @override
  Future<BranchDto> updateBranchManagerAccount(
    String branchId,
    String managerId,
    BranchManagerAccountRequestDto request,
  ) async {
    _throwIfNeeded();
    lastManagerAccountBranchId = branchId;
    lastManagerAccountManagerId = managerId;
    lastManagerAccountRequest = request;
    return _branch(branchId: branchId, managerId: managerId);
  }

  @override
  Future<BranchDto> resetBranchManagerPassword(
    String branchId,
    String managerId,
  ) async {
    _throwIfNeeded();
    lastManagerPasswordResetBranchId = branchId;
    lastManagerPasswordResetManagerId = managerId;
    return _branch(branchId: branchId, managerId: managerId);
  }

  @override
  Future<BranchDto> deleteBranchManagerAccount(
    String branchId,
    String managerId,
  ) async {
    _throwIfNeeded();
    lastManagerDeleteBranchId = branchId;
    lastManagerDeleteManagerId = managerId;
    return _branch(branchId: branchId);
  }

  @override
  Future<MedicineStatisticsDto> fetchMedicineStatistics(
    MedicineStatisticsFilterDto filter,
  ) async {
    _throwIfNeeded();
    lastMedicineStatisticsFilter = filter;
    return _medicineStatistics();
  }

  @override
  Future<BusinessAnalysisReportDto> fetchBusinessAnalysisReport(
    BusinessAnalysisFilterDto filter,
  ) async {
    _throwIfNeeded();
    lastBusinessAnalysisFilter = filter;
    return _businessAnalysisReport();
  }

  ProfileDto _profile({
    String fullName = 'Business Admin',
    String? phone = '0900000000',
  }) {
    return ProfileDto(
      userId: 'user-business-admin',
      fullName: fullName,
      email: 'businessadmin@pharmacy.com',
      role: 'BUSINESS_ADMIN',
      status: 'ACTIVE',
      phone: phone,
      branchName: 'Stratos Health',
      joinedDate: DateTime(2026, 7, 1),
    );
  }

  List<BranchDto> _branches() => [
    _branch(
      branchId: 'branch-1',
      branchName: 'Bach Mai Hospital Pharmacy',
      address: '78 Giai Phong, Hanoi',
      managerId: 'manager-1',
      managerName: 'Sarah Jenkins',
    ),
    _branch(
      branchId: 'branch-2',
      branchName: 'Da Nang Riverside Pharmacy',
      address: '2 Bach Dang, Da Nang',
    ),
  ];

  BranchDto _branch({
    String branchId = 'branch-1',
    String branchName = 'Bach Mai Hospital Pharmacy',
    String address = '78 Giai Phong, Hanoi',
    String status = 'ACTIVE',
    String? phone = '02438693731',
    double? latitude = 21.0017,
    double? longitude = 105.8416,
    String? managerId,
    String? managerName,
  }) {
    return BranchDto(
      branchId: branchId,
      branchName: branchName,
      address: address,
      status: status,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
      managerId: managerId,
      managerName: managerName,
      managerEmail: managerName == null ? null : 'manager@pharmacy.com',
      dailyRevenue: 1250000,
      staffCount: 9,
    );
  }

  MedicineStatisticsDto _medicineStatistics() {
    final item = MedicineInventoryItemDto(
      medicineId: 'medicine-1',
      medicineName: 'Amoxicillin 500mg',
      category: 'Antibiotic',
      branchName: 'Bach Mai Hospital Pharmacy',
      batchNumber: 'BATCH-001',
      quantityOnHand: 1420,
      safetyStockLevel: 400,
      expiryDate: DateTime(2027, 7),
      status: 'IN_STOCK',
    );

    return MedicineStatisticsDto(
      generatedAt: DateTime(2026, 7, 19),
      totalMedicines: 15,
      outOfStockCount: 1,
      lowStockCount: 2,
      nearExpiryCount: 3,
      fulfillmentRate: 94,
      inventoryItems: [item],
      bestSellingList: const [
        MedicineRankingItemDto(
          medicineId: 'medicine-1',
          medicineName: 'Amoxicillin 500mg',
          quantitySold: 120,
          revenue: 5400000,
        ),
      ],
      lowStockList: [item],
      nearExpiryList: [item],
    );
  }

  BusinessAnalysisReportDto _businessAnalysisReport() {
    return BusinessAnalysisReportDto(
      reportId: 'report-1',
      generatedAt: DateTime(2026, 7, 19),
      summary: const BusinessAnalysisSummaryDto(
        totalRevenue: 12889577,
        netProfitMargin: 24.8,
        customerGrowth: 5.1,
        averageBasketSize: 20823,
        completedTransactionCount: 320,
      ),
      revenueTrend: const [
        RevenueTrendDto(period: 'Jul', revenue: 12889577),
      ],
      salesByCategory: const [
        CategorySalesDto(category: 'Prescription Drugs', revenue: 5800000),
      ],
      branchFinancialSummary: const [
        BranchFinancialSummaryDto(
          branchId: 'branch-1',
          branchName: 'Bach Mai Hospital Pharmacy',
          revenue: 1245000,
          status: 'Efficient',
        ),
      ],
    );
  }
}
