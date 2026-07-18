import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// 1. FEFO (First Expired, First Out) Allocation Engine Logic
// ---------------------------------------------------------------------------
List<Map<String, dynamic>> allocateBatchesFEFO(List<Map<String, dynamic>> availableLots, int orderQty) {
  // Sort lots by expiry date ascending (FEFO rule)
  final sortedLots = List<Map<String, dynamic>>.from(availableLots)
    ..sort((a, b) => DateTime.parse(a['expDate']).compareTo(DateTime.parse(b['expDate'])));

  int remainingNeeded = orderQty;
  final List<Map<String, dynamic>> allocatedList = [];

  for (var lot in sortedLots) {
    if (remainingNeeded <= 0) break;
    int currentQty = lot['qty'] as int;
    if (currentQty <= 0) continue;

    int allocatedQty = (currentQty >= remainingNeeded) ? remainingNeeded : currentQty;
    allocatedList.add({
      'lotNo': lot['lotNo'],
      'expDate': lot['expDate'],
      'allocatedQty': allocatedQty,
    });
    remainingNeeded -= allocatedQty;
  }
  return allocatedList;
}

// ---------------------------------------------------------------------------
// 2. GS1 DataMatrix Barcode & Serialization Parser Logic
// ---------------------------------------------------------------------------
Map<String, String> parseGS1DataMatrix(String rawScan) {
  final result = <String, String>{};
  // Example GS1 string: (01)08935001234567(17)270115(10)LOT-GSK-081(21)SN99887766
  final gtinMatch = RegExp(r'\(01\)([^(\(]+)').firstMatch(rawScan);
  final expMatch = RegExp(r'\(17\)([^(\(]+)').firstMatch(rawScan);
  final lotMatch = RegExp(r'\(10\)([^(\(]+)').firstMatch(rawScan);
  final serialMatch = RegExp(r'\(21\)([^(\(]+)').firstMatch(rawScan);

  if (gtinMatch != null) result['GTIN'] = gtinMatch.group(1)!;
  if (expMatch != null) result['EXP_DATE'] = expMatch.group(1)!;
  if (lotMatch != null) result['LOT_NO'] = lotMatch.group(1)!;
  if (serialMatch != null) result['SERIAL_NO'] = serialMatch.group(1)!;

  return result;
}

// ---------------------------------------------------------------------------
// 3. Multi-Step QC Inspection Compliance Check
// ---------------------------------------------------------------------------
String evaluateQcCompliance({
  required bool tempCompliant,
  required bool packagingIntact,
  required bool coaVerified,
  required double assayPercentage,
}) {
  if (!tempCompliant) return 'Quarantined - Temperature Deviation';
  if (!packagingIntact) return 'Quarantined - Damaged Packaging';
  if (!coaVerified) return 'Quarantined - Missing/Invalid COA';
  if (assayPercentage < 95.0 || assayPercentage > 105.0) return 'Quarantined - Lab Assay Out of Spec';
  return 'Passed QC - Ready for Storage';
}

// ---------------------------------------------------------------------------
// 4. Cold Chain Temperature Alert Monitor
// ---------------------------------------------------------------------------
String checkColdChainStatus(double currentTempCelcius, {double minTemp = 2.0, double maxTemp = 8.0}) {
  if (currentTempCelcius < minTemp) return 'ALERT_UNDER_TEMP (Too Cold / Freeze Risk)';
  if (currentTempCelcius > maxTemp) return 'ALERT_OVER_TEMP (Exceeded GSP Max Temp)';
  return 'OPTIMAL_COLD_STORAGE';
}

// ---------------------------------------------------------------------------
// UNIT TEST SUITE
// ---------------------------------------------------------------------------
void main() {
  group('🏥 Enterprise Pharma WMS & GSP Compliance Unit Tests', () {
    test('1. FEFO Engine tự động ưu tiên xuất lô có hạn dùng gần nhất trước', () {
      final availableLots = [
        {'lotNo': 'LOT-2028', 'expDate': '2028-06-01', 'qty': 500},
        {'lotNo': 'LOT-2026', 'expDate': '2026-12-01', 'qty': 100}, // Hạn gần nhất
        {'lotNo': 'LOT-2027', 'expDate': '2027-08-01', 'qty': 300}, // Hạn thứ 2
      ];

      // Yêu cầu xuất 250 hộp
      final allocated = allocateBatchesFEFO(availableLots, 250);

      expect(allocated.length, equals(2));
      // Lô 1 được chọn: LOT-2026 với toàn bộ 100 hộp
      expect(allocated[0]['lotNo'], equals('LOT-2026'));
      expect(allocated[0]['allocatedQty'], equals(100));
      // Lô 2 được chọn: LOT-2027 với 150 hộp còn thiếu
      expect(allocated[1]['lotNo'], equals('LOT-2027'));
      expect(allocated[1]['allocatedQty'], equals(150));
    });

    test('2. GS1 DataMatrix Parser giải mã chính xác GTIN, Expiry, Lot và Serial Number', () {
      const rawBarcode = '(01)08935001234567(17)270115(10)LOT-2026-GSK-081(21)SN99887766';
      final parsed = parseGS1DataMatrix(rawBarcode);

      expect(parsed['GTIN'], equals('08935001234567'));
      expect(parsed['EXP_DATE'], equals('270115'));
      expect(parsed['LOT_NO'], equals('LOT-2026-GSK-081'));
      expect(parsed['SERIAL_NO'], equals('SN99887766'));
    });

    test('3. Multi-Step QC Kiểm định đúng 4 điều kiện: Nhiệt độ, Bao bì, COA và Độ tinh khiết Lab', () {
      // Trường hợp đạt chuẩn 100%
      final passedResult = evaluateQcCompliance(
        tempCompliant: true,
        packagingIntact: true,
        coaVerified: true,
        assayPercentage: 99.8,
      );
      expect(passedResult, equals('Passed QC - Ready for Storage'));

      // Trường hợp rách bao bì
      final damagedResult = evaluateQcCompliance(
        tempCompliant: true,
        packagingIntact: false,
        coaVerified: true,
        assayPercentage: 99.8,
      );
      expect(damagedResult, equals('Quarantined - Damaged Packaging'));

      // Trường hợp assay ngoài tiêu chuẩn (< 95% hoặc > 105%)
      final labFailResult = evaluateQcCompliance(
        tempCompliant: true,
        packagingIntact: true,
        coaVerified: true,
        assayPercentage: 92.5,
      );
      expect(labFailResult, equals('Quarantined - Lab Assay Out of Spec'));
    });

    test('4. Cold Chain Monitor phát hiện chính xác cảnh báo vượt hoặc dưới ngưỡng nhiệt độ bảo quản 2-8°C', () {
      expect(checkColdChainStatus(4.2), equals('OPTIMAL_COLD_STORAGE'));
      expect(checkColdChainStatus(1.1), equals('ALERT_UNDER_TEMP (Too Cold / Freeze Risk)'));
      expect(checkColdChainStatus(10.5), equals('ALERT_OVER_TEMP (Exceeded GSP Max Temp)'));
    });
  });
}
