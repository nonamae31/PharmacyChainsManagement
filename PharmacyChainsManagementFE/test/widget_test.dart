import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pharmacy_chains_management_fe/features/auth/control/auth_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/auth/network/auth_api_client.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/boundary/branch_management_screen.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/boundary/business_admin_shell_screen.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/boundary/business_analysis_report_screen.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/boundary/medicine_statistics_screen.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/boundary/profile_screen.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/control/business_admin_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/branch_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/business_analysis_report_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/forgot_password_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/medicine_statistics_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/entity/profile_dto.dart';
import 'package:pharmacy_chains_management_fe/features/business_admin/network/business_admin_api_client.dart';

void main() {
  testWidgets('Business Admin shell exposes all tabs', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              authApiClient: AuthApiClient(),
              localAuth: LocalAuthentication(),
            ),
          ),
          BlocProvider<BusinessAdminBloc>(
            create: (_) => BusinessAdminBloc(
              businessAdminApiClient: _FakeBusinessAdminApiClient(),
            ),
          ),
        ],
        child: const MaterialApp(home: BusinessAdminShellScreen()),
      ),
    );

    expect(find.text('Business Admin'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Medicine Statistics'), findsOneWidget);
    expect(find.text('Business Report'), findsOneWidget);
  });

  testWidgets('Business Admin profile screen renders fetched data', (
    tester,
  ) async {
    await _pumpBusinessAdminWidget(tester, const ProfileScreen());
    await tester.pumpAndSettle();

    expect(find.text('Business Admin User'), findsWidgets);
    expect(find.text('business.admin@pharmacy.test'), findsWidgets);
  });

  testWidgets('Business Admin branch screen renders fetched branches', (
    tester,
  ) async {
    await _pumpBusinessAdminWidget(tester, const BranchManagementScreen());
    await tester.pumpAndSettle();

    expect(find.text('Central Branch'), findsWidgets);
    expect(find.text('123 Pharmacy Street'), findsWidgets);
  });

  testWidgets('Business Admin medicine statistics screen renders inventory', (
    tester,
  ) async {
    await _pumpBusinessAdminWidget(tester, const MedicineStatisticsScreen());
    await tester.pumpAndSettle();

    expect(find.text('Medicine Statistics'), findsOneWidget);
    expect(find.text('Fulfillment Rate'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('INVENTORY MASTER LIST'), findsOneWidget);
    expect(find.text('Paracetamol'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Check stock receipt'), findsOneWidget);

    await tester.tap(find.text('Check stock receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Check stock receipt'), findsOneWidget);
    expect(find.text('Medicine front photo'), findsOneWidget);
    expect(find.text('Medicine back photo'), findsOneWidget);

    await tester.tap(find.text('Medicine front photo'));
    await tester.pumpAndSettle();

    expect(find.text('Box front side'), findsWidgets);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(find.text('Rejection reason is required'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).last,
      'Medicine photo does not match the selected inventory item.',
    );
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Stock receipt rejected for Paracetamol'),
      findsOneWidget,
    );
  });

  testWidgets('Business Admin report screen renders financial summary', (
    tester,
  ) async {
    await _pumpBusinessAdminWidget(
      tester,
      const BusinessAnalysisReportScreen(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Business Analysis Report'), findsOneWidget);
    expect(find.text('Revenue Growth & Projections'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Sales by Category'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Central Branch'), findsWidgets);
    expect(find.textContaining('1,000'), findsWidgets);
  });
}

Future<void> _pumpBusinessAdminWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    BlocProvider<BusinessAdminBloc>(
      create: (_) => BusinessAdminBloc(
        businessAdminApiClient: _FakeBusinessAdminApiClient(),
      ),
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

class _FakeBusinessAdminApiClient extends BusinessAdminApiClient {
  _FakeBusinessAdminApiClient()
    : super(dio: Dio(BaseOptions(baseUrl: 'http://localhost')));

  @override
  Future<ProfileDto> fetchProfile() async => ProfileDto(
    userId: 'user-1',
    fullName: 'Business Admin User',
    email: 'business.admin@pharmacy.test',
    role: 'BusinessAdmin',
    status: 'Active',
    phone: '0900000000',
    branchName: 'Central Branch',
    joinedDate: DateTime(2026),
  );

  @override
  Future<ProfileDto> updateProfile(UpdateProfileRequestDto request) async =>
      fetchProfile();

  @override
  Future<void> requestForgotPassword(ForgotPasswordRequestDto request) async {}

  @override
  Future<void> resetPassword(ResetPasswordRequestDto request) async {}

  @override
  Future<List<BranchDto>> fetchBranches({
    String? search,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async => const [
    BranchDto(
      branchId: 'branch-1',
      branchName: 'Central Branch',
      address: '123 Pharmacy Street',
      status: 'Active',
      phone: '0900000000',
      managerName: 'Store Manager',
    ),
  ];

  @override
  Future<BranchDto> createBranch(BranchRequestDto request) async =>
      (await fetchBranches()).first;

  @override
  Future<BranchDto> updateBranch(
    String branchId,
    BranchRequestDto request,
  ) async => (await fetchBranches()).first;

  @override
  Future<MedicineStatisticsDto> fetchMedicineStatistics(
    MedicineStatisticsFilterDto filter,
  ) async => MedicineStatisticsDto(
    generatedAt: DateTime(2026),
    totalMedicines: 1,
    outOfStockCount: 0,
    lowStockCount: 0,
    nearExpiryCount: 0,
    fulfillmentRate: 100,
    inventoryItems: [
      MedicineInventoryItemDto(
        medicineId: 'medicine-1',
        medicineName: 'Paracetamol',
        branchName: 'Central Branch',
        quantityOnHand: 50,
        safetyStockLevel: 10,
        status: 'InStock',
      ),
    ],
    bestSellingList: const [
      MedicineRankingItemDto(
        medicineId: 'medicine-1',
        medicineName: 'Paracetamol',
        quantitySold: 25,
        revenue: 250,
      ),
    ],
    lowStockList: const [],
    nearExpiryList: const [],
  );

  @override
  Future<BusinessAnalysisReportDto> fetchBusinessAnalysisReport(
    BusinessAnalysisFilterDto filter,
  ) async => BusinessAnalysisReportDto(
    generatedAt: DateTime(2026),
    summary: const BusinessAnalysisSummaryDto(
      totalRevenue: 1000,
      completedTransactionCount: 10,
      netProfitMargin: 20,
      customerGrowth: 5,
      averageBasketSize: 100,
    ),
    revenueTrend: const [RevenueTrendDto(period: '2026-01', revenue: 1000)],
    salesByCategory: const [
      CategorySalesDto(category: 'Pain Relief', revenue: 500),
    ],
    branchFinancialSummary: const [
      BranchFinancialSummaryDto(
        branchId: 'branch-1',
        branchName: 'Central Branch',
        revenue: 1000,
        status: 'Active',
      ),
    ],
  );
}
