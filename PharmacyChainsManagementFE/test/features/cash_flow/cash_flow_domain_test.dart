import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/cash_flow/domain/entities/cash_flow_statistics_entity.dart';

void main() {
  group('💸 Cash Flow Unit Test - Domain Entities', () {
    test('CashFlowDailyDataEntity so sánh Equatable chính xác theo ngày và dòng tiền', () {
      final date = DateTime(2026, 7, 18);
      final daily1 = CashFlowDailyDataEntity(
        date: date,
        inflow: 5000000.0,
        outflow: 1200000.0,
      );
      final daily2 = CashFlowDailyDataEntity(
        date: date,
        inflow: 5000000.0,
        outflow: 1200000.0,
      );

      expect(daily1, equals(daily2));
      expect(daily1.inflow - daily1.outflow, equals(3800000.0));
    });

    test('CashFlowStatisticsEntity quản lý tổng dòng tiền thu chi ròng chính xác', () {
      final date = DateTime(2026, 7, 18);
      final daily = [
        CashFlowDailyDataEntity(date: date, inflow: 10000000.0, outflow: 4000000.0),
      ];

      final stats = CashFlowStatisticsEntity(
        totalInflow: 10000000.0,
        totalOutflow: 4000000.0,
        netCashFlow: 6000000.0,
        dailyData: daily,
      );

      expect(stats.netCashFlow, equals(stats.totalInflow - stats.totalOutflow));
      expect(stats.dailyData.first.inflow, equals(10000000.0));
    });
  });
}
