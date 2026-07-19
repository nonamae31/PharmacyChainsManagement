import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/receive_goods_screen.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/control/receive_goods_bloc.dart';
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

  testWidgets('Receive Goods screen renders inbound form and items list correctly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeApiClient = _FakeInventoryApiClient();

    await tester.pumpWidget(
      BlocProvider<ReceiveGoodsBloc>(
        create: (_) => ReceiveGoodsBloc(fakeApiClient),
        child: const MaterialApp(
          home: Scaffold(
            body: ReceiveGoodsScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('WMS Receive Goods & Putaway (Quản Lý Nhập Kho & Vị Trí Cất)'), findsOneWidget);
    expect(find.text('Panadol Extra 500mg (Paracetamol & Caffeine)'), findsWidgets);
    expect(find.text('📦 Xác Nhận Nhập Kho & Gán Vị Trí WMS (Putaway)'), findsOneWidget);
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
