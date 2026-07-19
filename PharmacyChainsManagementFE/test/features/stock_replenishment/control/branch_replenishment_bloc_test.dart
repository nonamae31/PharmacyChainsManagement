import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/network/network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/control/branch_replenishment_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/control/branch_replenishment_event.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/control/branch_replenishment_state.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/entity/stock_replenishment_dto.dart';
import 'package:pharmacy_chains_management_fe/features/stock_replenishment/network/stock_replenishment_api_client.dart';

class _MockStockReplenishmentApiClient extends Mock
    implements StockReplenishmentApiClient {}

void main() {
  late _MockStockReplenishmentApiClient apiClient;

  const option = StockReplenishmentOptionDto(
    medicineId: 'medicine-1',
    medicineName: 'Omeprazole 20mg',
    category: 'Gastrointestinal',
    unit: 'Box',
    currentStock: 10,
    reorderPoint: 20,
  );
  final request = StockReplenishmentRequestDto(
    requestId: 'request-1',
    requestNo: 'REQ-20260719-ABC123',
    branchId: 'branch-1',
    branchName: 'Branch 1',
    requestedBy: 'manager-1',
    requestedByName: 'Manager',
    priority: 'URGENT',
    status: 'PENDING',
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
  final shippedRequest = StockReplenishmentRequestDto(
    requestId: 'request-1',
    requestNo: 'REQ-20260719-ABC123',
    branchId: 'branch-1',
    branchName: 'Branch 1',
    requestedBy: 'manager-1',
    requestedByName: 'Manager',
    priority: 'URGENT',
    status: 'SHIPPED',
    notes: null,
    inventoryNote: null,
    requestDate: DateTime(2026, 7, 19),
    processedAt: DateTime.utc(2026, 7, 19),
    transferId: 'transfer-1',
    sourceBranchName: 'Central Warehouse',
    dispatchedAt: DateTime.utc(2026, 7, 19),
    createdAt: DateTime.utc(2026, 7, 19),
    items: request.items,
  );
  final fulfilledRequest = StockReplenishmentRequestDto(
    requestId: shippedRequest.requestId,
    requestNo: shippedRequest.requestNo,
    branchId: shippedRequest.branchId,
    branchName: shippedRequest.branchName,
    requestedBy: shippedRequest.requestedBy,
    requestedByName: shippedRequest.requestedByName,
    priority: shippedRequest.priority,
    status: 'FULFILLED',
    notes: null,
    inventoryNote: null,
    requestDate: shippedRequest.requestDate,
    processedAt: shippedRequest.processedAt,
    transferId: shippedRequest.transferId,
    sourceBranchName: shippedRequest.sourceBranchName,
    dispatchedAt: shippedRequest.dispatchedAt,
    receivedAt: DateTime.utc(2026, 7, 19, 1),
    createdAt: shippedRequest.createdAt,
    items: shippedRequest.items,
  );
  const createRequest = CreateStockReplenishmentRequestDto(
    priority: 'URGENT',
    notes: null,
    items: [
      CreateStockReplenishmentItemDto(medicineId: 'medicine-1', quantity: 12),
    ],
  );

  setUpAll(() {
    registerFallbackValue(createRequest);
  });

  setUp(() {
    apiClient = _MockStockReplenishmentApiClient();
  });

  blocTest<BranchReplenishmentBloc, BranchReplenishmentState>(
    'loads medicine options and branch request history from the API',
    setUp: () {
      when(apiClient.fetchBranchOptions).thenAnswer((_) async => [option]);
      when(apiClient.fetchBranchRequests).thenAnswer((_) async => [request]);
    },
    build: () => BranchReplenishmentBloc(apiClient),
    act: (bloc) => bloc.add(const BranchReplenishmentFetchRequested()),
    expect: () => [
      const BranchReplenishmentLoading(),
      BranchReplenishmentLoadSuccess(
        options: const [option],
        requests: [request],
      ),
    ],
  );

  blocTest<BranchReplenishmentBloc, BranchReplenishmentState>(
    'submits a database request and refreshes branch history',
    setUp: () {
      when(
        () => apiClient.createBranchRequest(any()),
      ).thenAnswer((_) async => request);
      when(apiClient.fetchBranchRequests).thenAnswer((_) async => [request]);
    },
    seed: () =>
        const BranchReplenishmentLoadSuccess(options: [option], requests: []),
    build: () => BranchReplenishmentBloc(apiClient),
    act: (bloc) => bloc.add(const BranchReplenishmentSubmitted(createRequest)),
    expect: () => [
      const BranchReplenishmentLoadSuccess(
        options: [option],
        requests: [],
        submitting: true,
      ),
      BranchReplenishmentSubmitSuccess(
        options: const [option],
        requests: [request],
        createdRequest: request,
      ),
    ],
  );

  blocTest<BranchReplenishmentBloc, BranchReplenishmentState>(
    'keeps loaded data when the API rejects a duplicate open request',
    setUp: () {
      when(
        () => apiClient.createBranchRequest(any()),
      ).thenThrow(const ServerException('An open request already exists.'));
    },
    seed: () =>
        const BranchReplenishmentLoadSuccess(options: [option], requests: []),
    build: () => BranchReplenishmentBloc(apiClient),
    act: (bloc) => bloc.add(const BranchReplenishmentSubmitted(createRequest)),
    expect: () => [
      const BranchReplenishmentLoadSuccess(
        options: [option],
        requests: [],
        submitting: true,
      ),
      const BranchReplenishmentSubmitFailure(
        options: [option],
        requests: [],
        message: 'An open request already exists.',
      ),
    ],
  );

  blocTest<BranchReplenishmentBloc, BranchReplenishmentState>(
    'confirms receipt then refreshes stock options and request history',
    setUp: () {
      when(
        () => apiClient.confirmBranchReceived('request-1'),
      ).thenAnswer((_) async => fulfilledRequest);
      when(apiClient.fetchBranchOptions).thenAnswer((_) async => [option]);
      when(
        apiClient.fetchBranchRequests,
      ).thenAnswer((_) async => [fulfilledRequest]);
    },
    seed: () => BranchReplenishmentLoadSuccess(
      options: const [option],
      requests: [shippedRequest],
    ),
    build: () => BranchReplenishmentBloc(apiClient),
    act: (bloc) =>
        bloc.add(const BranchReplenishmentReceiptConfirmed('request-1')),
    expect: () => [
      BranchReplenishmentLoadSuccess(
        options: const [option],
        requests: [shippedRequest],
        receivingRequestId: 'request-1',
      ),
      BranchReplenishmentReceiptSuccess(
        options: const [option],
        requests: [fulfilledRequest],
      ),
    ],
  );
}
