import 'package:flutter_test/flutter_test.dart';
import 'package:baguncart_flutter/main.dart';

void main() {
  testWidgets('BaguncartApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BaguncartApp());

    // Verify that the login screen is displayed
    expect(find.text('BagunçArt'), findsOneWidget);
    expect(find.text('Sistema Administrativo'), findsOneWidget);
  });
}