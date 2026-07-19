import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/stocktake_screen.dart';
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

  testWidgets('Stocktake screen renders audit items and discrepancy actions correctly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeApiClient = _FakeInventoryApiClient();

    await tester.pumpWidget(
      BlocProvider<StocktakeBloc>(
        create: (_) => StocktakeBloc(fakeApiClient),
        child: const MaterialApp(
          home: Scaffold(
            body: StocktakeScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stocktake Management (Kiểm kê kho Thực tế & Blind Count)'), findsOneWidget);
    expect(find.text('Panadol Extra 500mg'), findsWidgets);
    expect(find.text('Confirm & Log Stocktake (Submit to Supervisor & Manager)'), findsOneWidget);
  });
}

class _FakeInventoryApiClient extends InventoryApiClient {
  _FakeInventoryApiClient()
      : super(Dio(BaseOptions(baseUrl: 'http://localhost')));

  @override
  Future<InventoryValuationResponseDto> getInventoryValuation(String branchId) async {
    return const InventoryValuationResponseDto(totalValue: 0, items: []);
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
