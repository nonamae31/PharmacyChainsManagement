import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/qc_inspection_screen.dart';

void main() {
  testWidgets('QC Inspection screen renders quarantine batches and verification actions properly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QcInspectionScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('QC Inspection (Kiểm tra chất lượng GSP/GDP & Lưu mẫu)'), findsOneWidget);
    expect(find.text('Pass QC & Approve (Duyệt đạt chuẩn QC & Ký số)'), findsWidgets);
    expect(find.text('Reject & Return (Từ chối & Hoàn trả)'), findsWidgets);
  });
}
