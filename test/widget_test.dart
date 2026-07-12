import 'package:flutter_test/flutter_test.dart';

import 'package:health_companion/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthCompanionApp());

    // Verify the splash screen renders with the app title.
    expect(find.text('Health Companion'), findsOneWidget);
  });
}
