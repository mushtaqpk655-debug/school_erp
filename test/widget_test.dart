import 'package:flutter_test/flutter_test.dart';
import 'package:school_erp/main.dart'; // Make sure this matches your project name

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SchoolApp());

    // Verify that our app starts.
    // This is a "Smoke Test" - it just checks if the app crashes on start.
    expect(find.byType(SchoolApp), findsOneWidget);
  });
}