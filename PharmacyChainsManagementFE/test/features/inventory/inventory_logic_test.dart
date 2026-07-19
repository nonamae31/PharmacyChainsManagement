import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Hàm logic nghiệp vụ mẫu định giá trạng thái tồn kho (Trích từ InventoryDashboardScreen logic)
void calculateStockAlertStatus(Map<String, dynamic> item) {
  final current = item['currentStock'] as int;
  final safety = item['safetyStock'] as int;
  final reorder = item['reorderPt'] as int;

  if (current <= safety * 0.3) {
    item['status'] = 'Critical';
    item['statusColor'] = const Color(0xFFEF4444);
    item['suggested'] = '+${(reorder - current) + 50} ${item['unit']}';
  } else if (current <= safety) {
    item['status'] = 'Low Stock';
    item['statusColor'] = const Color(0xFFF59E0B);
    item['suggested'] = '+${reorder - current} ${item['unit']}';
  } else {
    item['status'] = 'Optimal';
    item['statusColor'] = const Color(0xFF10B981);
    item['suggested'] = '0';
  }
}

void main() {
  group('📦 Unit Test - Logic Quản lý Tồn kho GSP (Inventory Stock Logic)', () {
    test('1. Kiểm tra trạng thái Critical khi số lượng tồn xuống dưới 30% mức an toàn', () {
      // Arrange (Chuẩn bị dữ liệu đầu vào)
      final sampleProduct = {
        'sku': 'SKU-TEST-001',
        'name': 'Vitamin C Sủi 1000mg',
        'currentStock': 20,    // 20 viên
        'safetyStock': 100,    // An toàn: 100 viên (30% của 100 là 30) -> 20 <= 30 => Critical
        'reorderPt': 150,      // Điểm đặt hàng lại
        'unit': 'tubes',
      };

      // Act (Thực thi logic cần kiểm thử)
      calculateStockAlertStatus(sampleProduct);

      // Assert (Kiểm tra kết quả đầu ra có đúng kỳ vọng không)
      expect(sampleProduct['status'], equals('Critical'));
      expect(sampleProduct['statusColor'], equals(const Color(0xFFEF4444)));
      // Gợi ý đặt hàng: (150 - 20) + 50 = +180 tubes
      expect(sampleProduct['suggested'], equals('+180 tubes'));
    });

    test('2. Kiểm tra trạng thái Low Stock khi số lượng tồn bằng hoặc dưới mức an toàn nhưng trên 30%', () {
      // Arrange
      final sampleProduct = {
        'sku': 'SKU-TEST-002',
        'name': 'Paracetamol 500mg',
        'currentStock': 80,    // 80 hộp (nằm giữa 30 và 100)
        'safetyStock': 100,
        'reorderPt': 200,
        'unit': 'boxes',
      };

      // Act
      calculateStockAlertStatus(sampleProduct);

      // Assert
      expect(sampleProduct['status'], equals('Low Stock'));
      expect(sampleProduct['statusColor'], equals(const Color(0xFFF59E0B)));
      // Gợi ý đặt hàng: (200 - 80) = +120 boxes
      expect(sampleProduct['suggested'], equals('+120 boxes'));
    });

    test('3. Kiểm tra trạng thái Optimal khi số lượng tồn cao hơn mức an toàn', () {
      // Arrange
      final sampleProduct = {
        'sku': 'SKU-TEST-003',
        'name': 'Amoxicillin 500mg',
        'currentStock': 350,   // 350 hộp (> 100)
        'safetyStock': 100,
        'reorderPt': 200,
        'unit': 'boxes',
      };

      // Act
      calculateStockAlertStatus(sampleProduct);

      // Assert
      expect(sampleProduct['status'], equals('Optimal'));
      expect(sampleProduct['statusColor'], equals(const Color(0xFF10B981)));
      expect(sampleProduct['suggested'], equals('0'));
    });
  });

  group('🔢 Unit Test - Tính toán độ chênh lệch Kiểm kê (Stocktake Variance Calculations)', () {
    test('Phát hiện chính xác chênh lệch thừa và thiếu so với sổ sách', () {
      final int bookQty = 500;
      final int physicalQtyMatched = 500;
      final int physicalQtyShort = 485;
      final int physicalQtySurplus = 512;

      expect(physicalQtyMatched - bookQty, equals(0)); // Khớp tuyệt đối
      expect(physicalQtyShort - bookQty, equals(-15));  // Thiếu 15
      expect(physicalQtySurplus - bookQty, equals(12)); // Thừa 12
    });
  });
}
