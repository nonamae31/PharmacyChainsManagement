import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pharmacy_chains_management_fe/core/constants/app_strings.dart';
import 'package:pharmacy_chains_management_fe/core/exceptions.dart';
import 'package:pharmacy_chains_management_fe/features/staff_sales/control/staff_sales_bloc.dart';
import 'package:pharmacy_chains_management_fe/features/staff_sales/control/staff_sales_event.dart';
import 'package:pharmacy_chains_management_fe/features/staff_sales/control/staff_sales_state.dart';
import 'package:pharmacy_chains_management_fe/features/staff_sales/entity/staff_sales_dto.dart';
import 'package:pharmacy_chains_management_fe/features/staff_sales/network/staff_sales_api_client.dart';

class MockStaffSalesApiClient extends Mock implements StaffSalesApiClient {}

void main() {
  late MockStaffSalesApiClient apiClient;

  const medicine = MedicineDto(
    medicineId: 'medicine-1',
    medicineName: 'Paracetamol',
    category: 'Pain relief',
    unit: 'Box',
    unitPrice: 12.5,
    availableQuantity: 3,
    safetyStockLevel: 1,
    stockStatus: 'AVAILABLE',
  );
  const secondMedicine = MedicineDto(
    medicineId: 'medicine-2',
    medicineName: 'Vitamin C',
    category: null,
    unit: 'Bottle',
    unitPrice: 20,
    availableQuantity: 10,
    safetyStockLevel: 2,
    stockStatus: 'AVAILABLE',
  );
  const dashboard = StaffDashboardDto(
    todayRevenue: 100,
    todayInvoiceCount: 2,
    pendingInvoiceCount: 1,
    lowStockItemCount: 3,
    shiftLabel: 'Morning',
  );
  const invoice = InvoiceDto(
    invoiceId: 'invoice-1',
    invoiceCode: 'INV-001',
    invoiceDate: '2026-07-19',
    totalAmount: 12.5,
    paymentStatus: 'UNPAID',
    status: 'ACTIVE',
    items: [],
  );
  final payment = PaymentDto(
    paymentId: 'payment-1',
    invoiceId: 'invoice-1',
    invoiceCode: 'INV-001',
    amount: 12.5,
    exchangeRate: 25000,
    expectedAmountVnd: 312500,
    receivedAmountVnd: null,
    baseCurrency: 'USD',
    settlementCurrency: 'VND',
    paymentMethod: 'BANK_TRANSFER',
    paymentStatus: 'PENDING',
    qrCodeUrl: null,
    bankName: null,
    accountName: null,
    accountNumber: null,
    transferContent: null,
    expiresAt: DateTime(2026, 7, 19, 12),
  );

  setUp(() {
    apiClient = MockStaffSalesApiClient();
  });

  StaffSalesBloc buildBloc() => StaffSalesBloc(apiClient: apiClient);

  group('StaffSalesBloc state transitions', () {
    test('should start in StaffSalesInitial', () async {
      final bloc = buildBloc();
      expect(bloc.state, isA<StaffSalesInitial>());
      await bloc.close();
    });

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should emit loading then dashboard success when dashboard API succeeds',
      setUp: () {
        when(() => apiClient.getDashboard()).thenAnswer((_) async => dashboard);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(StaffDashboardRequested()),
      expect: () => [
        isA<StaffSalesLoading>(),
        const StaffDashboardLoadSuccess(dashboard),
      ],
      verify: (_) => verify(() => apiClient.getDashboard()).called(1),
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should emit API message when dashboard API throws AppException',
      setUp: () {
        when(
          () => apiClient.getDashboard(),
        ).thenThrow(const ServerException('Dashboard unavailable'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(StaffDashboardRequested()),
      expect: () => [
        isA<StaffSalesLoading>(),
        const StaffSalesLoadFailure('Dashboard unavailable'),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should emit unknown error when medicine search throws unexpected error',
      setUp: () {
        when(
          () => apiClient.searchMedicines(search: any(named: 'search')),
        ).thenThrow(StateError('unexpected'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const MedicineSearchRequested('para')),
      expect: () => [
        isA<StaffSalesLoading>(),
        const StaffSalesLoadFailure(AppStrings.unknownError),
      ],
      verify: (_) {
        verify(() => apiClient.searchMedicines(search: 'para')).called(1);
      },
    );
  });

  group('Invoice draft equivalence partitions and boundaries', () {
    test('should expose the empty invoice subtotal as zero VND', () {
      expect(invoiceDraftTotalVnd(const InvoiceDraftReady([], 0)), 0);
    });

    test('should convert the invoice subtotal from USD to VND', () {
      expect(invoiceDraftTotalVnd(const InvoiceDraftReady([], 5)), 125000);
    });

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should create an empty draft when no initial medicine is supplied',
      build: buildBloc,
      act: (bloc) => bloc.add(const InvoiceDraftStarted(null)),
      expect: () => [const InvoiceDraftReady([], 0)],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should create quantity one draft at the lower valid boundary',
      build: buildBloc,
      act: (bloc) => bloc.add(const InvoiceDraftStarted(medicine)),
      expect: () => [
        const InvoiceDraftReady([
          InvoiceDraftLineModel(medicine: medicine, quantity: 1),
        ], 12.5),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should add distinct medicine and calculate the combined total',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceMedicineAdded(secondMedicine));
      },
      expect: () => [
        const InvoiceDraftReady([
          InvoiceDraftLineModel(medicine: medicine, quantity: 1),
        ], 12.5),
        const InvoiceDraftReady([
          InvoiceDraftLineModel(medicine: medicine, quantity: 1),
          InvoiceDraftLineModel(medicine: secondMedicine, quantity: 1),
        ], 32.5),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should increment quantity when the same medicine is added again',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceMedicineAdded(medicine));
      },
      expect: () => [
        const InvoiceDraftReady([
          InvoiceDraftLineModel(medicine: medicine, quantity: 1),
        ], 12.5),
        const InvoiceDraftReady([
          InvoiceDraftLineModel(medicine: medicine, quantity: 2),
        ], 25),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should reject quantity zero below the lower valid boundary',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceMedicineQuantityChanged('medicine-1', '0'));
      },
      expect: () => [
        isA<InvoiceDraftReady>(),
        isA<InvoiceDraftValidationFailure>().having(
          (state) => state.message,
          'message',
          AppStrings.invalidMedicineQuantity,
        ),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should accept quantity exactly equal to available stock',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceMedicineQuantityChanged('medicine-1', '3'));
      },
      expect: () => [
        isA<InvoiceDraftReady>(),
        const InvoiceDraftReady([
          InvoiceDraftLineModel(medicine: medicine, quantity: 3),
        ], 37.5),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should reject stock plus one at the upper invalid boundary',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceMedicineQuantityChanged('medicine-1', '4'));
      },
      expect: () => [
        isA<InvoiceDraftReady>(),
        isA<InvoiceDraftValidationFailure>().having(
          (state) => state.message,
          'message',
          AppStrings.insufficientMedicineStock,
        ),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should reject non-numeric quantity without changing the draft',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceMedicineQuantityChanged('medicine-1', 'abc'));
      },
      expect: () => [
        isA<InvoiceDraftReady>(),
        isA<InvoiceDraftValidationFailure>()
            .having((state) => state.lines.single.quantity, 'quantity', 1)
            .having(
              (state) => state.message,
              'message',
              AppStrings.invalidMedicineQuantity,
            ),
      ],
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should remove the selected medicine from the draft',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceMedicineRemoved('medicine-1'));
      },
      expect: () => [isA<InvoiceDraftReady>(), const InvoiceDraftReady([], 0)],
    );
  });

  group('Checkout currency conversion', () {
    test('should convert the checkout total from USD to VND', () {
      const checkoutInvoice = InvoiceSummaryDto(
        invoiceId: 'invoice-1',
        invoiceCode: 'INV-001',
        invoiceDate: '2026-07-19',
        totalAmount: 5,
        paymentStatus: 'UNPAID',
        status: 'ACTIVE',
        itemCount: 1,
      );

      expect(checkoutTotalVnd(checkoutInvoice), 125000);
    });

    test('should return zero VND for a zero-value checkout', () {
      const checkoutInvoice = InvoiceSummaryDto(
        invoiceId: 'invoice-2',
        invoiceCode: 'INV-002',
        invoiceDate: '2026-07-19',
        totalAmount: 0,
        paymentStatus: 'UNPAID',
        status: 'ACTIVE',
        itemCount: 0,
      );

      expect(checkoutTotalVnd(checkoutInvoice), 0);
    });
  });

  group('Invoice submission decision table', () {
    blocTest<StaffSalesBloc, StaffSalesState>(
      'should reject submission when the draft is empty',
      build: buildBloc,
      act: (bloc) => bloc.add(const InvoiceSubmitted()),
      expect: () => [
        const InvoiceDraftValidationFailure(
          [],
          0,
          AppStrings.invoiceRequiresMedicine,
        ),
      ],
      verify: (_) => verifyNever(() => apiClient.createInvoice(any())),
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should submit mapped medicine lines when the draft is valid',
      setUp: () {
        when(
          () => apiClient.createInvoice(any()),
        ).thenAnswer((_) async => invoice);
      },
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceSubmitted());
      },
      expect: () => [
        isA<InvoiceDraftReady>(),
        isA<InvoiceSubmitting>().having((state) => state.total, 'total', 12.5),
        const InvoiceSubmitSuccess(invoice),
      ],
      verify: (_) {
        final captured =
            verify(() => apiClient.createInvoice(captureAny())).captured.single
                as List<InvoiceLineRequestDto>;
        expect(captured, const [
          InvoiceLineRequestDto(medicineId: 'medicine-1', quantity: 1),
        ]);
      },
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should preserve draft and API message when submission fails',
      setUp: () {
        when(
          () => apiClient.createInvoice(any()),
        ).thenThrow(const ServerException('Insufficient stock'));
      },
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const InvoiceDraftStarted(medicine))
          ..add(const InvoiceSubmitted());
      },
      expect: () => [
        isA<InvoiceDraftReady>(),
        isA<InvoiceSubmitting>(),
        isA<InvoiceSubmitFailure>()
            .having((state) => state.lines.single.quantity, 'quantity', 1)
            .having((state) => state.total, 'total', 12.5)
            .having((state) => state.message, 'message', 'Insufficient stock'),
      ],
    );
  });

  group('Payment status use cases', () {
    blocTest<StaffSalesBloc, StaffSalesState>(
      'should refresh payment status successfully',
      setUp: () {
        when(
          () => apiClient.getPayment('payment-1'),
        ).thenAnswer((_) async => payment);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(PaymentStatusRequested(payment)),
      expect: () => [
        PaymentStatusRefreshInProgress(payment),
        PaymentStatusLoadSuccess(payment),
      ],
      verify: (_) => verify(() => apiClient.getPayment('payment-1')).called(1),
    );

    blocTest<StaffSalesBloc, StaffSalesState>(
      'should preserve payment and expose API error when refresh fails',
      setUp: () {
        when(
          () => apiClient.getPayment('payment-1'),
        ).thenThrow(const ServerException('Payment expired'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(PaymentStatusRequested(payment)),
      expect: () => [
        PaymentStatusRefreshInProgress(payment),
        PaymentStatusRefreshFailure(payment, 'Payment expired'),
      ],
    );
  });
}
