import 'package:flutter/foundation.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Pharmacy Roles Login E2E Test', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    final emailField = find.byValueKey('emailField');
    final passwordField = find.byValueKey('passwordField');
    final loginButton = find.byValueKey('loginButton');
    final signInButton = find.text('Sign In');

    final testCases = [
      {'email': 'founder@pharmacy.com', 'password': 'Founder@123', 'expectedTitle': 'Founder Dashboard'},
      {'email': 'businessadmin@pharmacy.com', 'password': '123456', 'expectedTitle': 'Business Admin Dashboard'},
      {'email': 'manager@pharmacy.com', 'password': '123456', 'expectedTitle': 'Branch Manager Dashboard'},
      {'email': 'staff@pharmacy.com', 'password': '123456', 'expectedTitle': 'Staff Dashboard'},
      {'email': 'inventory@pharmacy.com', 'password': '123456', 'expectedTitle': 'Inventory Dashboard'},
    ];

    test('Login for all 5 roles', () async {
      for (final testCase in testCases) {
        final email = testCase['email']!;
        final password = testCase['password']!;
        final expectedTitle = testCase['expectedTitle']!;

        debugPrint('--- Testing login for $email ---');

        // If not already on login screen (like just started or logged out), wait for 'Sign In'
        try {
          await driver.waitFor(signInButton, timeout: const Duration(seconds: 5));
          await driver.tap(signInButton);
        } catch (e) {
          debugPrint('Sign In button not found, probably already in the form');
        }

        try {
          await driver.waitFor(emailField, timeout: const Duration(seconds: 3));
        } catch (e) {
          debugPrint('Email field not found, maybe stuck on a dashboard. Attempting to logout...');
          try {
            await driver.tap(find.byType('IconButton'));
            await driver.waitFor(emailField, timeout: const Duration(seconds: 3));
          } catch (e) {
             debugPrint('Still no email field. Might be a different issue.');
          }
        }
        await driver.tap(emailField);
        await driver.enterText(email);

        // Enter password
        await driver.tap(passwordField);
        await driver.enterText(password);

        // Tap Login
        await driver.tap(loginButton);

        // Wait for Home Screen Dashboard Text to appear
        final homeDashboard = find.text(expectedTitle);
        await driver.waitFor(homeDashboard, timeout: const Duration(seconds: 15));
        debugPrint('✅ Reached home dashboard for $email');

        // Tap Logout button (assuming it's a Tooltip 'Logout' or we tap back)
        // Since we didn't add a key, we'll try to find by type 'IconButton' or Tooltip 'Back' 
        // For testing purpose without restarting, we can just restart the driver or tap back
        // Wait, since we are looping, let's use driver.requestData('restart') if we implemented it, or just tap the IconButton
        try {
            await driver.tap(find.byType('IconButton'));
            debugPrint('✅ Logged out');
        } catch (e) {
            debugPrint('Logout button not found, restarting app state might be needed');
        }
      }
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}
