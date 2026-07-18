import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/cash_flow_statistics_entity.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/repositories/cash_flow_repository.dart';
import '../datasources/cash_flow_remote_datasource.dart';
import '../models/cash_flow_model.dart';

class CashFlowRepositoryImpl implements CashFlowRepository {
  final CashFlowRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  static const String _cachedCashFlowKey = 'CACHED_CASH_FLOW_STATISTICS';

  CashFlowRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<CashFlowStatisticsEntity> getCashFlow(String startDate, String endDate, {String? branchId}) async {
    try {
      final cashFlowModel = await remoteDataSource.getCashFlow(startDate, endDate, branchId: branchId);
      
      // Cache data safely
      await secureStorage.write(
        key: _cachedCashFlowKey,
        value: jsonEncode(cashFlowModel.toJson()),
      );

      return cashFlowModel;
    } catch (e) {
      // Fallback to cache if error
      final cachedDataString = await secureStorage.read(key: _cachedCashFlowKey);
      if (cachedDataString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(cachedDataString);
        return CashFlowModel.fromJson(jsonMap);
      }
      rethrow;
    }
  }

  @override
  Future<List<BranchEntity>> getBranches() async {
    final branchModels = await remoteDataSource.getBranches();
    return branchModels.map((e) => BranchEntity(id: e.id, name: e.name)).toList();
  }
}
