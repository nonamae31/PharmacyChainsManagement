import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/batch_expiry_management_screen.dart';

void main() {
  testWidgets('Batch Expiry Management screen renders batch list and actions properly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BatchExpiryManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Batch Traceability & Serialization Tracking (Tra cứu Số lô, Hạn dùng & Serialization)'), findsOneWidget);
    expect(find.text('Traceability Tree (Genealogy)'), findsWidgets);
    expect(find.text('Trigger Emergency Recall'), findsWidgets);
  });
}
