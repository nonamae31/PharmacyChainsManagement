import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/network/branch_manager_network_exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/branch_inventory/control/branch_inventory_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/branch_inventory/control/branch_inventory_event.dart';
import 'package:pharmacy_chains_management_fe/features/branch_inventory/control/branch_inventory_state.dart';
import 'package:pharmacy_chains_management_fe/features/branch_inventory/entity/branch_inventory_dto.dart';
import 'package:pharmacy_chains_management_fe/features/branch_inventory/network/branch_inventory_api_client.dart';

class MockBranchInventoryApiClient extends Mock
    implements BranchInventoryApiClient {}

BranchInventoryDto _inventory({
  int page = 1,
  int totalRecords = 21,
  List<BranchInventoryRowDto>? items,
}) => BranchInventoryDto(
  branchId: 'branch-01',
  totalItems: totalRecords,
  criticalStock: 1,
  inTransit: 4,
  inventoryValue: 12500,
  page: page,
  pageSize: 10,
  totalRecords: totalRecords,
  categories: const ['Pain Relief', 'Vitamin'],
  items:
      items ??
      [
        BranchInventoryRowDto(
          medicineId: 'medicine-01',
          sku: 'SKU-001',
          medicineName: 'Paracetamol',
          category: 'Pain Relief',
          currentStock: 2,
          reorderPoint: 10,
          status: 'CRITICAL',
          supplier: 'Supplier A',
          lastSync: DateTime(2026, 7, 19, 10),
          inventoryValue: 500,
        ),
      ],
);

void main() {
  late MockBranchInventoryApiClient apiClient;

  setUp(() {
    apiClient = MockBranchInventoryApiClient();
  });

  group('UC33 - Monitor and Export Branch Inventory', () {
    test('ST-01: initial state should be BranchInventoryInitial', () {
      final bloc = BranchInventoryBloc(apiClient);
      expect(bloc.state, const BranchInventoryInitial());
      bloc.close();
    });

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'HP-01: should expose metrics, supplier, value and inbound quantity',
      build: () {
        when(
          () => apiClient.fetchInventory(
            search: null,
            category: null,
            status: null,
            page: 1,
          ),
        ).thenAnswer((_) async => _inventory());
        return BranchInventoryBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchInventoryFetchRequested()),
      expect: () => [
        const BranchInventoryLoading(),
        isA<BranchInventoryLoadSuccess>()
            .having((state) => state.inventory.totalItems, 'total items', 21)
            .having(
              (state) => state.inventory.criticalStock,
              'critical stock',
              1,
            )
            .having((state) => state.inventory.inTransit, 'inbound quantity', 4)
            .having(
              (state) => state.inventory.inventoryValue,
              'inventory value',
              12500,
            )
            .having(
              (state) => state.inventory.items.single.supplier,
              'supplier',
              'Supplier A',
            ),
      ],
      verify: (_) {
        verify(
          () => apiClient.fetchInventory(
            search: null,
            category: null,
            status: null,
            page: 1,
          ),
        ).called(1);
      },
    );

    final filterMatrix = [
      (search: 'para', category: 'Pain Relief', status: 'CRITICAL'),
      (search: 'SKU-001', category: 'all', status: 'ACTIVE'),
      (search: '', category: 'Vitamin', status: 'NORMAL'),
    ];

    for (final filters in filterMatrix) {
      blocTest<BranchInventoryBloc, BranchInventoryState>(
        'PW-01: should forward search=${filters.search}, category=${filters.category}, status=${filters.status}',
        build: () {
          when(
            () => apiClient.fetchInventory(
              search: filters.search,
              category: filters.category,
              status: filters.status,
              page: 1,
            ),
          ).thenAnswer((_) async => _inventory());
          return BranchInventoryBloc(apiClient);
        },
        act: (bloc) => bloc.add(
          BranchInventoryFetchRequested(
            search: filters.search,
            category: filters.category,
            status: filters.status,
          ),
        ),
        expect: () => [
          const BranchInventoryLoading(),
          isA<BranchInventoryLoadSuccess>()
              .having((state) => state.search, 'search', filters.search)
              .having((state) => state.category, 'category', filters.category)
              .having((state) => state.status, 'status', filters.status),
        ],
        verify: (_) {
          verify(
            () => apiClient.fetchInventory(
              search: filters.search,
              category: filters.category,
              status: filters.status,
              page: 1,
            ),
          ).called(1);
        },
      );
    }

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'BVA-01: should load the last page with fewer than pageSize records',
      build: () {
        when(
          () => apiClient.fetchInventory(
            search: null,
            category: null,
            status: null,
            page: 3,
          ),
        ).thenAnswer((_) async => _inventory(page: 3));
        return BranchInventoryBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchInventoryFetchRequested(page: 3)),
      expect: () => [
        const BranchInventoryLoading(),
        isA<BranchInventoryLoadSuccess>()
            .having((state) => state.inventory.page, 'page', 3)
            .having(
              (state) => state.inventory.items.length,
              'last page items',
              1,
            ),
      ],
    );

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'BVA-02: should treat an empty assigned branch inventory as a successful result',
      build: () {
        when(
          () => apiClient.fetchInventory(
            search: null,
            category: null,
            status: null,
            page: 1,
          ),
        ).thenAnswer((_) async => _inventory(totalRecords: 0, items: const []));
        return BranchInventoryBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchInventoryFetchRequested()),
      expect: () => [
        const BranchInventoryLoading(),
        isA<BranchInventoryLoadSuccess>()
            .having((state) => state.inventory.totalRecords, 'records', 0)
            .having((state) => state.inventory.items, 'items', isEmpty),
      ],
    );

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'SP-01: should preserve a known inventory API error',
      build: () {
        when(
          () => apiClient.fetchInventory(
            search: null,
            category: null,
            status: null,
            page: 1,
          ),
        ).thenThrow(
          const BranchManagerServerException('inventory unavailable'),
        );
        return BranchInventoryBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchInventoryFetchRequested()),
      expect: () => [
        const BranchInventoryLoading(),
        const BranchInventoryLoadFailure('inventory unavailable'),
      ],
    );

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'EG-01: should emit generic failure for malformed inventory JSON',
      build: () {
        when(
          () => apiClient.fetchInventory(
            search: null,
            category: null,
            status: null,
            page: 1,
          ),
        ).thenThrow(const FormatException('bad inventory payload'));
        return BranchInventoryBloc(apiClient);
      },
      act: (bloc) => bloc.add(const BranchInventoryFetchRequested()),
      expect: () => [
        const BranchInventoryLoading(),
        isA<BranchInventoryLoadFailure>(),
      ],
    );

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'HP-02: should export all assigned-branch inventory as CSV bytes',
      build: () {
        when(
          () => apiClient.exportInventory(),
        ).thenAnswer((_) async => [115, 107, 117, 44, 115, 116, 111, 99, 107]);
        return BranchInventoryBloc(apiClient);
      },
      seed: () => BranchInventoryLoadSuccess(inventory: _inventory()),
      act: (bloc) => bloc.add(const BranchInventoryExportRequested()),
      expect: () => [
        isA<BranchInventoryExportSuccess>().having(
          (state) => state.bytes,
          'CSV bytes',
          isNotEmpty,
        ),
      ],
      verify: (_) => verify(() => apiClient.exportInventory()).called(1),
    );

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'SP-02: should surface export failure instead of returning partial CSV',
      build: () {
        when(
          () => apiClient.exportInventory(),
        ).thenThrow(const BranchManagerServerException('export failed'));
        return BranchInventoryBloc(apiClient);
      },
      seed: () => BranchInventoryLoadSuccess(inventory: _inventory()),
      act: (bloc) => bloc.add(const BranchInventoryExportRequested()),
      expect: () => [const BranchInventoryLoadFailure('export failed')],
    );

    blocTest<BranchInventoryBloc, BranchInventoryState>(
      'ST-I1: export should be ignored before inventory is loaded',
      build: () => BranchInventoryBloc(apiClient),
      act: (bloc) => bloc.add(const BranchInventoryExportRequested()),
      expect: () => <BranchInventoryState>[],
      verify: (_) => verifyNever(() => apiClient.exportInventory()),
    );
  });
}
