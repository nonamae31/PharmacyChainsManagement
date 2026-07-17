import 'package:dio/dio.dart';
import '../models/cash_flow_model.dart';

abstract class CashFlowRemoteDataSource {
  Future<CashFlowModel> getCashFlow(String startDate, String endDate, {String? branchId});
}

class CashFlowRemoteDataSourceImpl implements CashFlowRemoteDataSource {
  final Dio dio;

  CashFlowRemoteDataSourceImpl({required this.dio});

  @override
  Future<CashFlowModel> getCashFlow(String startDate, String endDate, {String? branchId}) async {
    final Map<String, dynamic> queryParameters = {
      'startDate': startDate,
      'endDate': endDate,
    };
    if (branchId != null && branchId.isNotEmpty) {
      queryParameters['branchId'] = branchId;
    }

    final response = await dio.get('/api/finance/cash-flow', queryParameters: queryParameters);

    if (response.statusCode == 200) {
      return CashFlowModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load cash flow statistics');
    }
  }
}
