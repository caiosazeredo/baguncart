import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baguncart_cliente/main.dart';

void main() {
  testWidgets('BaguncartClienteApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BaguncartClienteApp());

    // Verify that the splash screen is displayed initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for splash screen animation
    await tester.pumpAndSettle(const Duration(seconds: 4));
    
    // Should navigate to login screen after splash
    expect(find.text('CPF'), findsOneWidget);
  });
}