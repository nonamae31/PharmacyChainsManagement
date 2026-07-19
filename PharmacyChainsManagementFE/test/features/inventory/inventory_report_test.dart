import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/inventory_report_screen.dart';

void main() {
  testWidgets('Inventory Report screen renders metrics and export options properly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryReportScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Inventory Reports & Analytics (Báo cáo Thống kê & Định giá)'), findsOneWidget);
    expect(find.text('Export PDF Report (Xuất báo cáo PDF)'), findsWidgets);
    expect(find.text('Export Excel Valuation (Xuất file Excel)'), findsWidgets);
  });
}
