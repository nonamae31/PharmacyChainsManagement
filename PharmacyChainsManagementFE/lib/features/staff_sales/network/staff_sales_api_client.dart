import 'package:dio/dio.dart';
import '../../../core/exceptions.dart';
import '../entity/staff_sales_dto.dart';

class StaffSalesApiClient {
  final Dio _dio;
  StaffSalesApiClient(this._dio);

  Future<List<MedicineDto>> searchMedicines({
    String? search,
    String? category,
    String? availability,
  }) async => _getList('/api/v1/staff-sales/medicines', {
    'search': search,
    'category': category,
    'availability': availability,
  }, MedicineDto.fromJson);
  Future<List<InvoiceSummaryDto>> getInvoices({
    String? search,
    String? paymentStatus,
  }) async => _getList('/api/v1/staff-sales/invoices', {
    'search': search,
    'paymentStatus': paymentStatus,
  }, InvoiceSummaryDto.fromJson);
  Future<InvoiceDto> getInvoice(String invoiceId) async => InvoiceDto.fromJson(
    await _get('/api/v1/staff-sales/invoices/$invoiceId'),
  );
  Future<List<PaymentDto>> getPayments() async =>
      _getList('/api/v1/staff-sales/payments', const {}, PaymentDto.fromJson);
  Future<StaffDashboardDto> getDashboard() async =>
      StaffDashboardDto.fromJson(await _get('/api/v1/staff-sales/dashboard'));
  Future<InvoiceDto> createInvoice(List<InvoiceLineRequestDto> items) async =>
      InvoiceDto.fromJson(
        await _post('/api/v1/staff-sales/invoices', {
          'items': items.map((item) => item.toJson()).toList(),
        }),
      );
  Future<PaymentDto> createPayment(
    String invoiceId,
    CreatePaymentRequestDto request,
  ) async => PaymentDto.fromJson(
    await _post(
      '/api/v1/staff-sales/invoices/$invoiceId/payments',
      request.toJson(),
    ),
  );
  Future<PaymentDto> getPayment(String paymentId) async => PaymentDto.fromJson(
    await _get('/api/v1/staff-sales/payments/$paymentId'),
  );

  Future<List<T>> _getList<T>(
    String path,
    Map<String, dynamic> query,
    T Function(Map<String, dynamic>) parser,
  ) async {
    final data = await _get(path, query);
    return (data as List)
        .map((item) => parser(item as Map<String, dynamic>))
        .toList();
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) async {
    final params = Map<String, dynamic>.from(query ?? const {})
      ..removeWhere((_, value) => value == null);
    try {
      return (await _dio.get(path, queryParameters: params)).data;
    } on DioException catch (error) {
      throw ServerException(_message(error));
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      return (await _dio.post(path, data: body)).data;
    } on DioException catch (error) {
      throw ServerException(_message(error));
    }
  }

  String _message(DioException error) =>
      error.response?.data is Map<String, dynamic>
      ? ((error.response?.data as Map<String, dynamic>)['detail'] ??
                (error.response?.data as Map<String, dynamic>)['message'] ??
                'Không thể hoàn tất yêu cầu.')
            .toString()
      : 'Không thể kết nối máy chủ.';
}
