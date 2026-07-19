import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/expired_stock_management_screen.dart';

void main() {
  testWidgets('Expired Stock Management screen renders expired items and disposal options properly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpiredStockManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Expired & Damaged Stock Management (Thuốc Hết hạn & Hư hỏng)'), findsOneWidget);
    expect(find.text('Return to Supplier (Hoàn trả nhà cung cấp)'), findsWidgets);
    expect(find.text('Create Disposal Report (Lập biên bản Tiêu hủy)'), findsWidgets);
  });
}
