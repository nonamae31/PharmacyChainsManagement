import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/features/inventory/boundary/internal_transfer_approval_screen.dart';

void main() {
  testWidgets('Internal Transfer Approval screen renders transfer requests and approval actions properly', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InternalTransferApprovalScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Internal Transfer Approval (Duyệt điều chuyển kho)'), findsOneWidget);
    expect(find.text('Approve Transfer (Phê duyệt điều chuyển)'), findsWidgets);
    expect(find.text('Reject Request (Từ chối phiếu)'), findsWidgets);
  });
}
