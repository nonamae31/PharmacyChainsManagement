import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmacy_chains_management_fe/features/auth/control/auth_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/auth/network/auth_api_client.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/inventory_dashboard_screen.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/control/inventory_dashboard_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/control/issue_stock_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/control/receive_goods_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/control/stocktake_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/entity/batch_traceability_response_dto.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/entity/inventory_valuation_response_dto.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/entity/issue_stock_request_dto.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/entity/receive_goods_request_dto.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/entity/stocktake_request_dto.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/network/inventory_api_client.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'BASE_URL=http://localhost');
  });

  testWidgets('Inventory Dashboard screen renders headers and statistics properly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeApiClient = _FakeInventoryApiClient();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              authApiClient: AuthApiClient(),
              localAuth: LocalAuthentication(),
            ),
          ),
          BlocProvider<InventoryDashboardBloc>(
            create: (_) => InventoryDashboardBloc(fakeApiClient),
          ),
          BlocProvider<ReceiveGoodsBloc>(
            create: (_) => ReceiveGoodsBloc(fakeApiClient),
          ),
          BlocProvider<IssueStockBloc>(
            create: (_) => IssueStockBloc(fakeApiClient),
          ),
          BlocProvider<StocktakeBloc>(
            create: (_) => StocktakeBloc(fakeApiClient),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: InventoryDashboardScreen(branchId: 'BR-01'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PRODUCT / SKU'), findsWidgets);
    expect(find.text('ABC / XYZ'), findsWidgets);
    expect(find.text('WMS LOCATION'), findsWidgets);
    expect(find.text('STOCK'), findsWidgets);
    expect(find.text('STATUS'), findsWidgets);
    expect(find.text('Add SKU / Stock'), findsWidgets);
  });
}

class _FakeInventoryApiClient extends InventoryApiClient {
  _FakeInventoryApiClient()
      : super(Dio(BaseOptions(baseUrl: 'http://localhost')));

  @override
  Future<InventoryValuationResponseDto> getInventoryValuation(String branchId) async {
    return const InventoryValuationResponseDto(
      totalValue: 1520450000.0,
      items: [
        InventoryValuationItemDto(
          medicineId: 'MED-001',
          medicineName: 'Panadol Extra',
          totalAvailableQuantity: 1500,
          averageCost: 50000.0,
          totalValue: 75000000.0,
        ),
      ],
    );
  }

  @override
  Future<void> receiveGoods(ReceiveGoodsRequestDto request) async {}

  @override
  Future<void> issueStock(IssueStockRequestDto request) async {}

  @override
  Future<void> submitStocktake(StocktakeRequestDto request) async {}

  @override
  Future<BatchTraceabilityResponseDto> getBatchTraceability(String batchId) async {
    return BatchTraceabilityResponseDto(
      batchId: batchId,
      batchNumber: batchId,
      currentStatus: 'PASSED',
      history: const [],
    );
  }
}
