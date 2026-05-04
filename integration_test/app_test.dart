import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:school_erp/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app flow test', (tester) async {
    app.main(); // Start the app
    await tester.pumpAndSettle(); // Wait for it to load

    // 1. Test Login
    final loginButton = find.text('Login');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 2. Verify we are on the Dashboard
    expect(find.text('Welcome, Admin'), findsOneWidget);

    // 3. Test Navigation to Fees
    await tester.tap(find.text('Fees Module'));
    await tester.pumpAndSettle();

    expect(find.text('Total Fees Collected'), findsOneWidget);
  });
}