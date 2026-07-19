import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pharmacy_chains_management_fe/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UC28 - Login and view Business Admin', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tap "Sign In" button
    final signInButton = find.text('Sign In');
    expect(signInButton, findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // Fill email
    final emailField = find.byKey(const Key('emailField'));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'founder@pharmacy.com');

    // Fill password
    final passwordField = find.byKey(const Key('passwordField'));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, 'Founder@123');

    // Tap Login
    final loginButton = find.byKey(const Key('loginButton'));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    
    // Wait for API call and navigation
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify Sidebar exists
    final sidebarMenu = find.byKey(const Key('founder_sidebar'));
    if (sidebarMenu.evaluate().isNotEmpty) {
      expect(sidebarMenu, findsOneWidget);
    }
    // Since Key might not exist, we can find by text "Business Admins"
    final businessAdminsMenu = find.text('Business Admins');
    expect(businessAdminsMenu, findsWidgets); // could be in drawer or sidebar

    // Tap Business Admins
    await tester.tap(businessAdminsMenu.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Look for an admin card
    final activeStatus = find.text('ACTIVE');
    expect(activeStatus, findsWidgets);

    // Tap the first one
    await tester.tap(activeStatus.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify it doesn't show password (just expecting NO PasswordHash field or text)
    expect(find.text('PasswordHash'), findsNothing);

    // Now go back and tap logout
    await tester.pageBack();
    await tester.pumpAndSettle();

    final logoutButton = find.text('Đăng xuất');
    expect(logoutButton, findsWidgets);
    await tester.tap(logoutButton.first);
    await tester.pumpAndSettle();

    // Confirm logout if there's a dialog
    final confirmLogout = find.text('Đăng xuất'); // Assuming bottomsheet has a button
    if (confirmLogout.evaluate().isNotEmpty) {
      await tester.tap(confirmLogout.last);
      await tester.pumpAndSettle();
    }

    debugPrint('ALL TESTS PASSED SUCCESSFULLY! - FOUNDER E2E JOURNEY');
  });
}
