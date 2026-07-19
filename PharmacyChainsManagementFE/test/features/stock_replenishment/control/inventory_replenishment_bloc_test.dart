import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/control/inventory_replenishment_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/control/inventory_replenishment_event.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/control/inventory_replenishment_state.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/entity/stock_replenishment_dto.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/network/stock_replenishment_api_client.dart';

class _MockStockReplenishmentApiClient extends Mock
    implements StockReplenishmentApiClient {}

void main() {
  late _MockStockReplenishmentApiClient apiClient;
  final pending = _request(status: 'PENDING');
  final processing = _request(status: 'PROCESSING');
  final shipped = _request(status: 'SHIPPED');
  const update = UpdateStockReplenishmentStatusDto(
    status: 'PROCESSING',
    inventoryNote: null,
  );
  const dispatch = DispatchStockReplenishmentDto(
    sourceBranchId: 'source-branch-1',
    inventoryNote: null,
  );
  const source = StockReplenishmentSourceDto(
    branchId: 'source-branch-1',
    branchName: 'Central Warehouse',
  );

  setUpAll(() {
    registerFallbackValue(update);
    registerFallbackValue(dispatch);
  });

  setUp(() {
    apiClient = _MockStockReplenishmentApiClient();
  });

  blocTest<InventoryReplenishmentBloc, InventoryReplenishmentState>(
    'loads live pending branch requests for Inventory',
    setUp: () {
      when(
        () => apiClient.fetchInventoryQueue(status: 'PENDING'),
      ).thenAnswer((_) async => [pending]);
    },
    build: () => InventoryReplenishmentBloc(apiClient),
    act: (bloc) =>
        bloc.add(const InventoryReplenishmentFetchRequested(status: 'PENDING')),
    expect: () => [
      const InventoryReplenishmentLoading(),
      InventoryReplenishmentLoadSuccess(requests: [pending], status: 'PENDING'),
    ],
  );

  blocTest<InventoryReplenishmentBloc, InventoryReplenishmentState>(
    'starts processing and refreshes the shared request queue',
    setUp: () {
      when(
        () => apiClient.updateInventoryStatus(any(), any()),
      ).thenAnswer((_) async => processing);
      when(
        () => apiClient.fetchInventoryQueue(status: 'ALL'),
      ).thenAnswer((_) async => [processing]);
    },
    seed: () =>
        InventoryReplenishmentLoadSuccess(requests: [pending], status: 'ALL'),
    build: () => InventoryReplenishmentBloc(apiClient),
    act: (bloc) => bloc.add(
      const InventoryReplenishmentStatusUpdated(
        requestId: 'request-1',
        request: update,
      ),
    ),
    expect: () => [
      InventoryReplenishmentLoadSuccess(
        requests: [pending],
        status: 'ALL',
        updating: true,
      ),
      InventoryReplenishmentUpdateSuccess(
        requests: [processing],
        status: 'ALL',
      ),
    ],
  );

  blocTest<InventoryReplenishmentBloc, InventoryReplenishmentState>(
    'loads source branches that can fulfil the request',
    setUp: () {
      when(
        () => apiClient.fetchDispatchSources('request-1'),
      ).thenAnswer((_) async => const [source]);
    },
    seed: () => InventoryReplenishmentLoadSuccess(
      requests: [processing],
      status: 'ALL',
    ),
    build: () => InventoryReplenishmentBloc(apiClient),
    act: (bloc) =>
        bloc.add(InventoryReplenishmentDispatchOptionsRequested(processing)),
    expect: () => [
      InventoryReplenishmentLoadSuccess(
        requests: [processing],
        status: 'ALL',
        updating: true,
      ),
      InventoryReplenishmentDispatchOptionsSuccess(
        requests: [processing],
        status: 'ALL',
        request: processing,
        sources: const [source],
      ),
    ],
  );

  blocTest<InventoryReplenishmentBloc, InventoryReplenishmentState>(
    'dispatches stock and refreshes the live queue',
    setUp: () {
      when(
        () => apiClient.dispatchInventoryRequest(any(), any()),
      ).thenAnswer((_) async => shipped);
      when(
        () => apiClient.fetchInventoryQueue(status: 'ALL'),
      ).thenAnswer((_) async => [shipped]);
    },
    seed: () => InventoryReplenishmentLoadSuccess(
      requests: [processing],
      status: 'ALL',
    ),
    build: () => InventoryReplenishmentBloc(apiClient),
    act: (bloc) => bloc.add(
      const InventoryReplenishmentDispatchSubmitted(
        requestId: 'request-1',
        request: dispatch,
      ),
    ),
    expect: () => [
      InventoryReplenishmentLoadSuccess(
        requests: [processing],
        status: 'ALL',
        updating: true,
      ),
      InventoryReplenishmentDispatchSuccess(requests: [shipped], status: 'ALL'),
    ],
  );
}

StockReplenishmentRequestDto _request({required String status}) {
  return StockReplenishmentRequestDto(
    requestId: 'request-1',
    requestNo: 'REQ-20260719-ABC123',
    branchId: 'branch-1',
    branchName: 'Branch 1',
    requestedBy: 'manager-1',
    requestedByName: 'Manager',
    priority: 'URGENT',
    status: status,
    notes: null,
    inventoryNote: null,
    requestDate: DateTime(2026, 7, 19),
    processedAt: null,
    createdAt: DateTime.utc(2026, 7, 19),
    items: const [
      StockReplenishmentItemDto(
        medicineId: 'medicine-1',
        medicineName: 'Omeprazole 20mg',
        unit: 'Box',
        requestedQuantity: 12,
      ),
    ],
  );
}
