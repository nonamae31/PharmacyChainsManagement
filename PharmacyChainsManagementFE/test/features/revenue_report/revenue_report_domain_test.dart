import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/revenue_report/domain/entities/revenue_report_response.dart';

void main() {
  group('📈 Revenue Report Unit Test - Domain Entities', () {
    test('RevenueItem lưu trữ chính xác mốc thời gian và doanh thu', () {
      const item = RevenueItem(date: '2026-07-18', amount: 15500000.0);

      expect(item.date, equals('2026-07-18'));
      expect(item.amount, equals(15500000.0));
    });

    test('RevenueReportResponse tính tổng doanh thu gộp và danh sách chi tiết ngày', () {
      const items = [
        RevenueItem(date: '2026-07-17', amount: 12000000.0),
        RevenueItem(date: '2026-07-18', amount: 18000000.0),
      ];

      const response = RevenueReportResponse(
        grossRevenue: 30000000.0,
        items: items,
      );

      final sumAmount = response.items.fold<double>(0, (sum, item) => sum + item.amount);
      expect(response.grossRevenue, equals(sumAmount));
      expect(response.items.length, equals(2));
    });
  });
}
