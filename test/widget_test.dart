import 'package:flutter_test/flutter_test.dart';
import 'package:school_erp/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SchoolApp());

    // Verify that the login screen is shown.
    expect(find.text('Login'), findsAtLeast(1));
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
