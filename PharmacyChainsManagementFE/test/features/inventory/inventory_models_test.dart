import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/entity/inventory_valuation_response_dto.dart';

void main() {
  group('📦 Inventory Unit Test - InventoryValuationItemDto', () {
    test('fromJson() parse chính xác số lượng tồn kho và định giá từ API', () {
      final json = {
        'medicineId': 'MED-001',
        'medicineName': 'Panadol Extra 500mg',
        'totalAvailableQuantity': 1200,
        'averageCost': 15000.5,
        'totalValue': 18000600.0,
      };

      final item = InventoryValuationItemDto.fromJson(json);

      expect(item.medicineId, equals('MED-001'));
      expect(item.medicineName, equals('Panadol Extra 500mg'));
      expect(item.totalAvailableQuantity, equals(1200));
      expect(item.averageCost, equals(15000.5));
      expect(item.totalValue, equals(18000600.0));
    });

    test('toJson() và Equatable equality kiểm tra hai đối tượng giống hệt nhau', () {
      const item1 = InventoryValuationItemDto(
        medicineId: 'MED-002',
        medicineName: 'Amoxicillin 500mg',
        totalAvailableQuantity: 500,
        averageCost: 20000.0,
        totalValue: 10000000.0,
      );

      const item2 = InventoryValuationItemDto(
        medicineId: 'MED-002',
        medicineName: 'Amoxicillin 500mg',
        totalAvailableQuantity: 500,
        averageCost: 20000.0,
        totalValue: 10000000.0,
      );

      expect(item1, equals(item2));
      expect(item1.toJson()['medicineId'], equals('MED-002'));
    });
  });

  group('📦 Inventory Unit Test - InventoryValuationResponseDto', () {
    test('parse trọn bộ danh sách hàng hóa và tổng giá trị kho từ server json response', () {
      final json = {
        'totalValue': 45000000.0,
        'items': [
          {
            'medicineId': 'MED-001',
            'medicineName': 'Panadol Extra 500mg',
            'totalAvailableQuantity': 1000,
            'averageCost': 15000.0,
            'totalValue': 15000000.0,
          },
          {
            'medicineId': 'MED-002',
            'medicineName': 'Vitamin C Sủi',
            'totalAvailableQuantity': 1000,
            'averageCost': 30000.0,
            'totalValue': 30000000.0,
          }
        ]
      };

      final response = InventoryValuationResponseDto.fromJson(json);

      expect(response.totalValue, equals(45000000.0));
      expect(response.items.length, equals(2));
      expect(response.items[1].medicineName, equals('Vitamin C Sủi'));
    });
  });
}
